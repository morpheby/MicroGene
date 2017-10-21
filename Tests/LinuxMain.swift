import XCTest
@testable import MicroGeneTests

XCTMain([
    testCase(CompartmentIndexTests.allTests),
    testCase(PathTests.allTests),
    testCase(StorageTests.allTests),
    testCase(PathExpressionTests.allTests),
    testCase(MatcherTests.allTests),
])
