import got from "got";
import { createWriteStream, existsSync, mkdirSync } from "fs";
import ffmpeg from "fluent-ffmpeg";
import { Job } from "./model/job";
import path from "path";
import logger from "../utils/logger";

async function writeFile(url: string, destinationFile: string) {
  logger.debug({ url, destinationFile }, "Starting file download");
  return new Promise<void>((resolve, reject) => {
    const writeStream = got
      .stream(url)
      .pipe(createWriteStream(destinationFile));
    writeStream.on("finish", () => {
      logger.debug({ url, destinationFile }, "File download completed");
      resolve();
    });
    writeStream.on("error", (error) => {
      logger.error({ url, destinationFile, error: error.message }, "File download failed");
      reject(error);
    });
  });
}

function jobDirectory(job: Job): string {
  const baseDir = process.env.NODE_ENV === 'development' 
    ? path.join(process.cwd(), job.destination.directory)
    : path.resolve(job.destination.directory);

  if (!existsSync(baseDir)) {
    logger.debug({ directory: baseDir }, "Creating output directory");
    mkdirSync(baseDir, { recursive: true });
  }
  return path.join(baseDir, job.id);
}

export async function processVideos(job: Job): Promise<void> {
  const jobId = job.id;
  logger.info({ jobId }, "Starting video processing");
  
  try {
    const jobDir = jobDirectory(job);
    if (!existsSync(jobDir)) {
      logger.debug({ jobId, directory: jobDir }, "Creating job directory");
      mkdirSync(jobDir, { recursive: true });
    }

    // Download all videos
    logger.info({ jobId, urls: job.sourceVideoUrls }, "Downloading videos");
    const filePaths: string[] = [];
    for (const [index, url] of job.sourceVideoUrls.entries()) {
      const filePath = path.join(jobDir, `${index}.mp4`);
      filePaths.push(filePath);
      await writeFile(url, filePath);
      logger.debug({ jobId, url, progress: `${index + 1}/${job.sourceVideoUrls.length}` }, "Video download progress");
    }

    // Merge videos
    const outputPath = path.join(jobDir, "output.mp4");
    logger.info({ jobId, inputFiles: filePaths, outputPath }, "Starting video merge");
    
    await new Promise<void>((resolve, reject) => {
      let command = ffmpeg();
      filePaths.forEach(filePath => {
        command = command.input(filePath);
      });

      command
        .on("progress", (progress) => {
          logger.debug({ jobId, progress: progress.percent }, "Merge progress");
        })
        .on("end", () => {
          logger.info({ jobId, outputPath }, "Video merge completed");
          resolve();
        })
        .on("error", (error) => {
          logger.error({ jobId, error: error.message }, "Error merging videos");
          reject(error);
        })
        .mergeToFile(outputPath);
    });

    logger.info({ jobId }, "Video processing completed successfully");
  } catch (error) {
    logger.error({ 
      jobId, 
      error: error instanceof Error ? error.message : "Unknown error",
      stack: error instanceof Error ? error.stack : undefined
    }, "Failed to process videos");
    throw error;
  }
}
