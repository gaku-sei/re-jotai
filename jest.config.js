module.exports = {
  testMatch: ["**/test/**/*_Test.js"],
  transform: {
    "\\.js$": "babel-jest",
  },
  transformIgnorePatterns: [
    "node_modules/(?!\\@glennsl\\/bs-jest|rescript|\\@rescriptbr\\/react-testing-library|bs-dom-testing-library)",
  ],
};
