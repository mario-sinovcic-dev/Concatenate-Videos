import got from "got";
import { createWriteStream, existsSync, mkdirSync } from "fs";
import ffmpeg from "fluent-ffmpeg";
import { Job } from "./model/job";

function writeFile(url: string, destinationFile: string) {
  return new Promise<void>((resolve) => {
    const writeStream = got
      .stream(url)
      .pipe(createWriteStream(destinationFile));
    writeStream.on("finish", resolve);
  });
}

function jobDirectory(job: Job): string {
  return `${job.destination.directory}/${job.id}`;
}

async function downloadVideos(job: Job): Promise<string[]> {
  const jobDir = jobDirectory(job);
  if (!existsSync(jobDir)) {
    mkdirSync(jobDir, { recursive: true });
  }
  let fileIndex = 0;
  const filePaths: string[] = [];
  await Promise.all(
    job.sourceVideoUrls.map((url) => {
      const filePath = `${jobDir}/${fileIndex++}.mp4`;
      filePaths.push(filePath);
      writeFile(url, filePath);
    })
  );
  return filePaths;
}

function mergeFiles(job: Job, filePaths: string[]) {
  return new Promise<void>((resolve, reject) => {
    let command = ffmpeg(filePaths[0]);
    filePaths.slice(1).forEach((filePath) => {
      command = command.input(filePath);
    });
    console.log(`Merging files using command '${command}'`);
    command
      .on("error", function (err) {
        console.log("An error occurred: " + err.message);
        reject(err);
      })
      .on("end", function () {
        console.log("Merging finished !");
        resolve();
      })
      .mergeToFile(`${jobDirectory(job)}/merged.mp4`);
  });
}

export async function processVideos(job: Job) {
  const filePaths = await downloadVideos(job);
  console.log(`downloaded ${job.sourceVideoUrls.length} files`);

  await mergeFiles(job, filePaths);
}
