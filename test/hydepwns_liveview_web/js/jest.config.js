/**
 * Jest Configuration for Component Testing
 * ---------------------------------------
 * Configuration for running Jest tests on components migrated to the robust component system.
 * Includes improved handling of ES Modules.
 */

module.exports = {
  // The root directory that Jest should scan for tests and modules
  rootDir: '../../../',
  
  // The test environment that will be used for testing
  testEnvironment: 'jsdom',
  
  // The glob patterns Jest uses to detect test files
  testMatch: [
    '**/test/hydepwns_liveview_web/js/components/**/*_test.js',
    '**/test/js/components/**/*_test.js'
  ],
  
  // An array of file extensions your modules use
  moduleFileExtensions: ['js', 'json', 'jsx', 'ts', 'tsx', 'node'],
  
  // A list of paths to directories that Jest should use to search for files in
  roots: [
    '<rootDir>/assets/js',
    '<rootDir>/test/hydepwns_liveview_web/js',
    '<rootDir>/test/js'
  ],
  
  // The directory where Jest should output its coverage files
  coverageDirectory: '<rootDir>/coverage',
  
  // Indicates whether each individual test should be reported during the run
  verbose: true,
  
  // Setup files to run before each test
  setupFilesAfterEnv: [
    '<rootDir>/test/hydepwns_liveview_web/js/setup.js'
  ],
  
  // Transform files with babel-jest
  transform: {
    '^.+\\.jsx?$': ['babel-jest', { rootMode: 'upward' }]
  },
  
  // Don't ignore transformations for these node_modules
  transformIgnorePatterns: [
    '/node_modules/(?!(sinon|@testing-library)/)'
  ],
  
  // Automatically clear mock calls and instances between every test
  clearMocks: true,
  
  // Collect coverage from these directories
  collectCoverageFrom: [
    'assets/js/components/**/*.js',
    '!assets/js/components/COMPONENT_MIGRATION_GUIDE.md'
  ],
  
  // The threshold for coverage results
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  
  // A map from regular expressions to module names that allow to stub out resources
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': '<rootDir>/test/hydepwns_liveview_web/js/__mocks__/styleMock.js',
    '\\.(gif|ttf|eot|svg|png)$': '<rootDir>/test/hydepwns_liveview_web/js/__mocks__/fileMock.js',
    '^@/(.*)$': '<rootDir>/assets/js/$1'
  }
}; 