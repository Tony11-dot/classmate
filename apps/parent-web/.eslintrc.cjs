module.exports = {
  root: true,
  extends: ['next/core-web-vitals', 'next/typescript'],
  ignorePatterns: [
    'node_modules/',
    '.next/',
    'dist/',
    'coverage/',
    'test-results/',
    'playwright-report/',
    'e2e/',
    'tests/',
  ],
};
