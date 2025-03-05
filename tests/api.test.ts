import { exec } from 'child_process';
import { promisify } from 'util';
import axios from 'axios';

const execAsync = promisify(exec);

// Helper function to manage Docker Compose
async function runDockerCompose(command: string): Promise<void> {
    try {
        await execAsync(`docker compose ${command}`);
        console.log(`Docker Compose ${command} completed successfully`);
    } catch (error) {
        console.error(`Error running docker compose ${command}:`, error);
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

describe('Video Concatenation API', () => {
    // Arrange
    beforeAll(async () => {
        // Start Docker Compose before all tests
        await runDockerCompose('up -d --build');
        // Wait for API to be ready
        await new Promise(resolve => setTimeout(resolve, 5000));
    });

    // Cleanup after all tests
    afterAll(async () => {
        await runDockerCompose('down');
    });

    it('should create a job successfully', async () => {
        // Arrange
        const requestBody = {
            sourceVideoUrls: ["https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"],
            destination: {
                directory: "./output"
            }
        };

        // Act
        const response = await axios.post('http://localhost:8000/jobs', requestBody);

        // Assert
        expect(response.status).toBe(201);
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('status');
        expect(typeof response.data.id).toBe('string');
        expect(response.data.id.length).toBeGreaterThan(0);
    });
}); 