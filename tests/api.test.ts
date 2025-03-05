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