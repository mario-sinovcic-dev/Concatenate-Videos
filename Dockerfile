# Build stage
FROM node:18-slim AS builder

# Install ffmpeg and curl - needed to run api tests
# TODO - move this to prod stage, if we're planning on adding unit tests instead
RUN apt-get update && \
    apt-get install -y ffmpeg curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create output directory with proper permissions
RUN mkdir -p /app/output && \
    chown -R node:node /app/output && \
    chmod 755 /app/output

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code, excpet .dockerignore specs
# TODO - bit of a smell, look to create staged builds for prod and test
COPY . .

# Build TypeScript
RUN npm run build

# Production stage
FROM builder AS production

# Set NODE_ENV
ENV NODE_ENV=production

# Switch to non-root user
USER node

# Expose the port the app runs on
EXPOSE 8000

# Start the application
CMD ["npm", "start"] 