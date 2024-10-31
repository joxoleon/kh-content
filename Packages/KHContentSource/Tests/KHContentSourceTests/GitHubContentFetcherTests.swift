import XCTest
@testable import KHContentSource

class GitHubContentFetcherTests: XCTestCase {
    
    var contentFetcher: GitHubContentFetcher!
    
    override func setUp() {
        super.setUp()
        contentFetcher = GitHubContentFetcher()
    }
    
    override func tearDown() {
        contentFetcher = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    func testFetchLessons() {
        let expectation = self.expectation(description: "Fetch lessons JSON from GitHub")
        
        contentFetcher.fetchLessons { result in
            switch result {
            case .success(let lessons):
                XCTAssertFalse(lessons.isEmpty, "Expected lessons to be non-empty")
                print("Fetched Lessons: \(lessons.count)")
            case .failure(let error):
                XCTFail("Failed to fetch lessons with error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchModules() {
        let expectation = self.expectation(description: "Fetch modules JSON from GitHub")
        
        contentFetcher.fetchModules { result in
            switch result {
            case .success(let modules):
                XCTAssertFalse(modules.isEmpty, "Expected modules to be non-empty")
                print("Fetched Modules: \(modules.count)")
            case .failure(let error):
                XCTFail("Failed to fetch modules with error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchContentMetadata() {
        let expectation = self.expectation(description: "Fetch content metadata JSON from GitHub")
        
        contentFetcher.fetchContentMetadata { result in
            switch result {
            case .success(let metadata):
                XCTAssertGreaterThan(metadata.lastUpdatedTimestamp, 0, "Expected valid timestamp in metadata")
                print("Fetched Metadata Timestamp: \(metadata.lastUpdatedTimestamp)")
            case .failure(let error):
                XCTFail("Failed to fetch content metadata with error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
