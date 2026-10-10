module.exports = {
  env: {
    browser: true,
    es2021: true,
    jquery: true,
  },
  extends: [
    'airbnb-base',
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'script',
  },
  rules: {
    'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    'no-console': 'off',
    'import/no-extraneous-dependencies': 'off',
    'no-shadow': 'off',
    'func-names': 'off',
    'prefer-arrow-callback': 'off',
    'no-plusplus': 'off',
    'no-param-reassign': 'off',
    'no-restricted-syntax': 'off',
    'no-continue': 'off',
    'guard-for-in': 'off',
    'consistent-return': 'off',
    'no-underscore-dangle': 'off',
  },
  globals: {
    L: 'readonly',
    Cookies: 'readonly',
    Paho: 'readonly',
    App: 'readonly',
  },
  ignorePatterns: [
    'web/assets/js/jquery*.js',
    'web/assets/js/bootstrap*.js',
    'web/assets/js/paho-mqtt.js',
    'web/assets/js/perfect-scrollbar/**',
    'web/assets/js/jquery-ui/**',
  ],
};