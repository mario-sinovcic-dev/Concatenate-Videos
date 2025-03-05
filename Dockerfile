FROM node:18-slim

# Install ffmpeg and curl
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
RUN npm install

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Switch to non-root user
USER node

# Expose the port the app runs on
EXPOSE 8000

# Start the application
CMD ["npm", "start"] 