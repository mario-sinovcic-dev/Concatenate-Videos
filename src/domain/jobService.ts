import { v4 as uuid } from 'uuid';

import {
  CreateJobRequest,
  CreateJobResponse,
  GetJobStatusResponse,
  Job,
  Status,
} from './model/job';
import { saveJob, getJob, getNextPendingJob, updateStatus } from '../repository/jobRepository';
import { processVideos } from './videoProcessor';
import logger from '../utils/logger';

// TODO: Update job service to use SQS for job queue
// TODO: Use S3 for video storage instead of local filesystem
// TODO: Add CloudWatch metrics for job processing
// TODO: Implement job status updates via DynamoDB streams
// TODO: Add retries and DLQ handling

export async function createJob(createJobRequest: CreateJobRequest): Promise<CreateJobResponse> {
  const jobId = uuid();
  logger.info({ jobId, request: createJobRequest }, 'Creating new job');

  const job: Job = new Job(
    jobId,
    createJobRequest.sourceVideoUrls,
    createJobRequest.destination,
    Status.pending,
  );
  await saveJob(job);
  logger.info({ jobId }, 'Job created successfully');
  return new CreateJobResponse(job.id);
}

export async function getStatus(id: string): Promise<GetJobStatusResponse> {
  logger.debug({ jobId: id }, 'Getting job status');
  const job = await getJob(id);
  if (!job) {
    logger.warn({ jobId: id }, 'Job not found');
    throw new Error(`job ${id} is not found`);
  }
  logger.debug({ jobId: id, status: Status[job.status] }, 'Retrieved job status');
  return new GetJobStatusResponse(Status[job.status]);
}

export async function processNextJob() {
  const job = await getNextPendingJob();
  if (!job) {
    logger.debug('No jobs to process');
    return;
  }

  const jobId = job.id;
  logger.info({ jobId }, 'Starting job processing');

  try {
    await updateStatus(jobId, Status.inProgress);
    logger.debug({ jobId }, 'Updated status to in progress');

    await processVideos(job);
    logger.info({ jobId }, 'Video processing completed');

    await updateStatus(jobId, Status.done);
    logger.info({ jobId }, 'Job completed successfully');
  } catch (error) {
    logger.error(
      {
        jobId,
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      },
      'Failed to process job',
    );

    await updateStatus(jobId, Status.error);
  }
}
