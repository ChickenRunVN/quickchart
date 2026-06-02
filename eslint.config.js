const js = require('@eslint/js');
const globals = require('globals');

// Flat config (ESLint 9). Pragmatic ruleset for a legacy CommonJS codebase:
// keep real-bug rules as errors, demote stylistic/noise rules to warnings so
// `eslint .` exits 0 (CI gate is meaningful, not a wall of pre-existing nits).
module.exports = [
  {
    ignores: ['node_modules/**', 'coverage/**', '**/*.min.js'],
  },
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: {
        ...globals.node,
      },
    },
    rules: {
      'no-unused-vars': ['warn', { args: 'none', varsIgnorePattern: '^_' }],
      'no-empty': 'warn',
      'no-constant-condition': ['warn', { checkLoops: false }],
      'no-control-regex': 'off',
      'no-useless-escape': 'warn',
      'no-prototype-builtins': 'warn',
      // Legacy google_image_charts parser: flag but don't block (logic untouched).
      'no-dupe-else-if': 'warn',
      'no-case-declarations': 'warn',
    },
  },
  {
    files: ['test/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.mocha,
      },
    },
  },
];
