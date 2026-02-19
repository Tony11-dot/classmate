/** @type {import('jest').Config} */
module.exports = {
  rootDir: '.',
  testEnvironment: 'node',
  testMatch: ['<rootDir>/src/**/*.spec.ts'],
  moduleFileExtensions: ['ts', 'js', 'json'],
  transform: { '^.+\\.(t|j)sx?$': ['@swc/jest'] },
  setupFiles: ['<rootDir>/src/test/jest.env.ts'],
  clearMocks: true,
};
