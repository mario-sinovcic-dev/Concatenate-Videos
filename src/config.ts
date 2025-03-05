// TODO: Update config to use AWS Parameter Store
// TODO: Add environment-specific configurations
// TODO: Add AWS service endpoints

export const config = {
  port: process.env.PORT ? parseInt(process.env.PORT, 10) : 8000,
  jobProcessingInterval: process.env.JOB_PROCESSING_INTERVAL
    ? parseInt(process.env.JOB_PROCESSING_INTERVAL, 10)
    : 2000,
  // TODO: Add AWS RDS config
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5432,
    name: process.env.DB_NAME || 'video_jobs',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
  },
  // TODO: Add AWS service configurations
  aws: {
    region: process.env.AWS_REGION || 'us-east-1',
    sqs: {
      queueUrl: process.env.SQS_QUEUE_URL || 'http://localhost:4566/000000000000/jobs',
    },
    s3: {
      bucket: process.env.S3_BUCKET || 'video-processing',
    },
  },
};
