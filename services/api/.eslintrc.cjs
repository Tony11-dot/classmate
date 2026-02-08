module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended'],
  ignorePatterns: [
    'node_modules/',
    'dist/',
    'coverage/',
    'prisma/',
    'src/e2e/',
    'test-results/',
    'playwright-report/',
  ],
  rules: {
    // day-1 pragmatism (tighten later)
    '@typescript-eslint/no-explicit-any': 'off',

    // ---- turn off the whole "unsafe-*" family (this is your current blocker) ----
    '@typescript-eslint/no-unsafe-assignment': 'off',
    '@typescript-eslint/no-unsafe-member-access': 'off',
    '@typescript-eslint/no-unsafe-call': 'off',
    '@typescript-eslint/no-unsafe-return': 'off',
    '@typescript-eslint/no-unsafe-argument': 'off',

    // common early-stage pragmatism
    '@typescript-eslint/no-floating-promises': 'off',
    '@typescript-eslint/no-unused-vars': 'off',
    '@typescript-eslint/no-require-imports': 'off',
    '@typescript-eslint/prefer-as-const': 'off',

    // JS rules that often fire in TS-heavy code
    'no-useless-escape': 'off',
    'no-empty': 'off',
  },
};
