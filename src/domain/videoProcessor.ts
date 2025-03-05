import got from "got";
import { createWriteStream, existsSync, mkdirSync } from "fs";
import ffmpeg from "fluent-ffmpeg";
import { Job } from "./model/job";
import path from "path";

function writeFile(url: string, destinationFile: string) {
  return new Promise<void>((resolve, reject) => {
    const writeStream = got
      .stream(url)
      .pipe(createWriteStream(destinationFile));
    writeStream.on("finish", resolve);
    writeStream.on("error", reject);
  });
}

function jobDirectory(job: Job): string {
  // Use relative path for local development, absolute path for Docker
  const baseDir = process.env.NODE_ENV === 'development' 
    ? path.join(process.cwd(), job.destination.directory)
    : path.resolve(job.destination.directory);

  if (!existsSync(baseDir)) {
    mkdirSync(baseDir, { recursive: true });
  }
  return path.join(baseDir, job.id);
}

async function downloadVideos(job: Job): Promise<string[]> {
  const jobDir = jobDirectory(job);
  if (!existsSync(jobDir)) {
    mkdirSync(jobDir, { recursive: true });
  }
  let fileIndex = 0;
  const filePaths: string[] = [];
  
  try {
    await Promise.all(
      job.sourceVideoUrls.map(async (url) => {
        const filePath = path.join(jobDir, `${fileIndex++}.mp4`);
        filePaths.push(filePath);
        await writeFile(url, filePath);
      })
    );
    return filePaths;
  } catch (error) {
    console.error("Error downloading videos:", error);
    throw error;
  }
}

function mergeFiles(job: Job, filePaths: string[]) {
  return new Promise<void>((resolve, reject) => {
    const outputPath = path.join(jobDirectory(job), "merged.mp4");
    let command = ffmpeg(filePaths[0]);
    
    filePaths.slice(1).forEach((filePath) => {
      command = command.input(filePath);
    });
    
    console.log(`Merging files to: ${outputPath}`);
    command
      .on("error", function (err) {
        console.error("An error occurred during merging:", err.message);
        reject(err);
      })
      .on("end", function () {
        console.log("Merging finished successfully!");
        resolve();
      })
      .mergeToFile(outputPath);
  });
}

export async function processVideos(job: Job) {
  try {
    const filePaths = await downloadVideos(job);
    console.log(`Successfully downloaded ${job.sourceVideoUrls.length} files`);

    await mergeFiles(job, filePaths);
  } catch (error) {
    console.error("Error processing videos:", error);
    throw error;
  }
}
