export default {
  displayName: 'betty',
  preset: '../../jest.preset.js',
  testEnvironment: 'node',
  transform: {
    '^.+\\.[tj]s$': ['ts-jest', { tsconfig: '<rootDir>/tsconfig.spec.json' }],
  },
  moduleFileExtensions: ['ts', 'js', 'html'],
  coverageDirectory: '../../coverage/apps/betty',
  // Suprimir logs durante tests
  silent: true,
  // Setup para configurar el logger de NestJS
  setupFilesAfterEnv: ['<rootDir>/src/test-setup.ts'],
};
