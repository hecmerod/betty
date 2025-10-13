export default {
  displayName: 'betty',
  preset: '../../jest.preset.js',
  testEnvironment: 'node',
  transform: {
    '^.+\\.[tj]s$': ['ts-jest', { tsconfig: '<rootDir>/tsconfig.spec.json' }],
  },
  moduleFileExtensions: ['ts', 'js', 'html'],
  coverageDirectory: '../../coverage/apps/betty',
  silent: true,
  setupFilesAfterEnv: ['<rootDir>/src/test-setup.ts'],
  maxWorkers: '75%',
  testTimeout: 10000,
  cache: true,
};
