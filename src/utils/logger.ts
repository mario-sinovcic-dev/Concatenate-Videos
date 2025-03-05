import pino from 'pino';

const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    timestamp: true,
    formatters: {
        level: (label) => {
            return { level: label };
        },
    },
    // Pretty print in development
    transport: process.env.NODE_ENV === 'development' 
        ? {
            target: 'pino-pretty',
            options: {
                colorize: true,
                translateTime: 'SYS:standard',
            },
        }
        : undefined,
});

export default logger; 