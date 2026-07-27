module.exports = {
  clearMocks: true,
  moduleFileExtensions: ['js', 'ts'],
  testEnvironment: 'node',
  testMatch: ['**/*.test.ts'],
  testRunner: 'jest-circus/runner',
  moduleNameMapper: {
    '^@actions/github$': '<rootDir>/tests/actions-github.mock.ts'
  },
  transform: {
    '^.+\\.ts$': 'ts-jest'
  },
  verbose: true
}