# Concatenate Videos

### Running the application

#### Using Docker (Recommended)

```bash
# Build and start the application
docker compose up --build

# To run in detached mode
docker compose up -d --build

# To stop the application
docker compose down
```

The API will run on port 8000.

#### Local OS Setup (Alternative)

1. Install OS-level dependencies:
```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y ffmpeg

# CentOS/RHEL
sudo yum install -y ffmpeg
```

2. Create output directory:
```bash
mkdir -p output
```

3. Install Node.js dependencies:
```bash
npm install
```

4. Start the application:
```bash
npm start
```

The API will run on port 8000.

### Running Tests

The project includes integration tests that verify the API functionality:

```bash
# Run all tests
cd tests

npm install

npm test

# Run tests in watch mode (for development)
npm test -- --watch

# Run tests with coverage report [TODO - currently, not configured correctly]
npm test -- --coverage
```

The tests will:
1. Start the application in Docker
2. Run the test suite
3. Clean up Docker resources

### API Call Flow

```
POST /jobs
{
    "sourceVideoUrls": ["<url to mp4>", "<url to another mp4>"],
    "destination": {
        "directory": "<local path of directory that'll store merged file>"
    }
}
```

returns

```
{
    "id": "<job id>"
    "status": "<url to status of job>"
}
```

```
GET /job/{jobId}/status
```

returns

```
{
    "status": "pending"
}
```

### Architecture

![Overview](./architecture-overview.png)
