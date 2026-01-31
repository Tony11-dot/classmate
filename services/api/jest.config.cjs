/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: 'node',

  // Transform TS -> JS for Jest
  transform: {
    '^.+\\.(t|j)sx?$': ['@swc/jest'],
  },

  moduleFileExtensions: ['ts', 'js', 'json'],

  // Your tests live under src/** including src/test/*.e2e.spec.ts
  roots: ['<rootDir>/src'],
  testMatch: ['**/*.spec.ts'],

  // Keep it simple; you can refine later
  clearMocks: true,
};
