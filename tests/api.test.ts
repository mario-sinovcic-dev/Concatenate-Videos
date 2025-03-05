import { exec } from 'child_process';
import { promisify } from 'util';
import axios from 'axios';

const execAsync = promisify(exec);
const API_URL = 'http://localhost:8000';

// Helper function to manage Docker Compose
async function runDockerCompose(command: string): Promise<void> {
    try {
        await execAsync(`docker compose ${command}`);
    } catch (error) {
        console.error(`Docker Compose error:`, error);
        throw error;
    }
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

jest.setTimeout(60000); // Reduced timeout

describe('Video Concatenation API', () => {
    // Arrange
    beforeAll(async () => {
        // Start Docker Compose before all tests
        await runDockerCompose('up -d --build');
        
        // Wait for API to be ready with health check
        let isApiReady = false;
        const maxRetries = 15;
        const retryInterval = 1000;
        
        for (let i = 0; i < maxRetries && !isApiReady; i++) {
            try {
                await axios.get(`${API_URL}/health`);
                isApiReady = true;
                console.log('API is ready');
            } catch (error) {
                console.log(`API not ready, attempt ${i + 1}/${maxRetries}`);
                await new Promise(resolve => setTimeout(resolve, retryInterval));
            }
        }

        if (!isApiReady) {
            throw new Error('API failed to become ready');
        }
    }, 60000);

    afterAll(async () => {
        try {
            await runDockerCompose('down');
        } catch (error) {
            console.error('Error during cleanup:', error);
        }
    }); // No timeout for cleanup

    it('should create a job successfully', async () => {
        // Arrange
        const requestBody = {
            sourceVideoUrls: ["https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"],
            destination: {
                directory: "./output"
            }
        };

        // Act
        const response = await axios.post(`${API_URL}/jobs`, requestBody);

        // Assert
        expect(response.status).toBe(201);
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('status');
        expect(typeof response.data.id).toBe('string');
        expect(response.data.id.length).toBeGreaterThan(0);
    }, 10000);
}); 