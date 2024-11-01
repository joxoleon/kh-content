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

    func testFetchLessons() async {
        do {
            let lessons = try await contentFetcher.fetchLessons()
            XCTAssertFalse(lessons.isEmpty, "Expected lessons to be non-empty")
            print("Fetched Lessons: \(lessons.count)")
        } catch {
            XCTFail("Failed to fetch lessons with error: \(error)")
        }
    }
    
    func testFetchModules() async {
        do {
            let modules = try await contentFetcher.fetchModules()
            XCTAssertFalse(modules.isEmpty, "Expected modules to be non-empty")
            print("Fetched Modules: \(modules.count)")
        } catch {
            XCTFail("Failed to fetch modules with error: \(error)")
        }
    }
    
    func testFetchContentMetadata() async {
        do {
            let metadata = try await contentFetcher.fetchContentMetadata()
            XCTAssertGreaterThan(metadata.lastUpdatedTimestamp, 0, "Expected valid timestamp in metadata")
            print("Fetched Metadata Timestamp: \(metadata.lastUpdatedTimestamp)")
        } catch {
            XCTFail("Failed to fetch content metadata with error: \(error)")
        }
    }
}
