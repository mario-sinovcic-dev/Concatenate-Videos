module.exports = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    testTimeout: 30000, // 30 seconds
    setupFilesAfterEnv: ['./jest.setup.js']
}; 