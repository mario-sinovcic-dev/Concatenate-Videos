import { exec } from 'child_process';
import { promisify } from 'util';
import axios from 'axios';

const execAsync = promisify(exec);
const API_URL = 'http://localhost:8000';

// Helper function to manage Docker Compose
async function runDockerCompose(command: string): Promise<void> {
    try {
        // Add --no-recreate for faster startup when container exists
        if (command === 'up -d --build') {
            await execAsync('docker compose up -d --no-recreate || docker compose up -d --build');
        } else {
            await execAsync(`docker compose ${command}`);
        }
    } catch (error) {
        console.error(`Docker Compose error:`, error);
        throw error;
    }
}

// Optimized health check with faster initial checks
async function waitForApi(maxRetries = 15): Promise<void> {
    // Start with quick checks
    for (let i = 0; i < 5; i++) {
        try {
            await axios.get(`${API_URL}/health`);
            console.log('API is ready');
            return;
        } catch (error) {
            await new Promise(resolve => setTimeout(resolve, 200));
        }
    }
    
    // If quick checks fail, fall back to slower checks
    for (let i = 5; i < maxRetries; i++) {
        try {
            await axios.get(`${API_URL}/health`);
            console.log('API is ready');
            return;
        } catch (error) {
            console.log(`API not ready, attempt ${i + 1}/${maxRetries}`);
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
    }
    
    throw new Error('API failed to become ready');
}

/**
 * TODO: Add more test cases to cover:
 * 1. Error cases:
 *    - Invalid video URLs
 *    - Non-existent output directory
 *    - Invalid request body format
 *    - Empty video URLs array
 * 
 * 2. Edge cases:
 *    - Very large video files
 *    - Multiple videos in one request
 *    - Special characters in output directory path
 *    - Concurrent job requests
 * 
 * 3. Job status checks:
 *    - Verify job status transitions (pending -> inProgress -> done)
 *    - Check job status for non-existent job ID
 *    - Verify job completion with actual output file
 * 
 * 4. Performance tests:
 *    - Measure response times
 *    - Test under load
 *    - Memory usage monitoring
 * 
 * 5. Integration scenarios:
 *    - Complete workflow from job creation to file download
 *    - Verify output file format and content
 *    - Test cleanup of temporary files
 */

jest.setTimeout(60000);

describe('Video Concatenation API', () => {
    beforeAll(async () => {
        await runDockerCompose('up -d --build');
        await waitForApi();
    }, 60000);

    afterAll(async () => {
        try {
            await runDockerCompose('down');
        } catch (error) {
            console.error('Error during cleanup:', error);
        }
    });

    it('should create a job successfully', async () => {
        const requestBody = {
            sourceVideoUrls: ["https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"],
            destination: {
                directory: "./output"
            }
        };

        const response = await axios.post(`${API_URL}/jobs`, requestBody);

        expect(response.status).toBe(201);
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('status');
        expect(typeof response.data.id).toBe('string');
        expect(response.data.id.length).toBeGreaterThan(0);
    }, 10000);
}); 