import XCTest
@testable import KHContentSource

// MARK: - Mocks for Testing

class MockContentFetcher: ContentFetcherProtocol {
    var mockMetadata: ContentMetadata?
    var mockLessons: [Lesson] = []
    var mockModules: [LearningModule] = []
    
    func fetchContentMetadata(completion: @escaping (Result<ContentMetadata, Error>) -> Void) {
        if let metadata = mockMetadata {
            completion(.success(metadata))
        } else {
            completion(.failure(NSError(domain: "Test", code: -1, userInfo: nil)))
        }
    }
    
    func fetchLessons(completion: @escaping (Result<[Lesson], Error>) -> Void) {
        completion(.success(mockLessons))
    }
    
    func fetchModules(completion: @escaping (Result<[LearningModule], Error>) -> Void) {
        completion(.success(mockModules))
    }
}

class MockContentStorage: ContentStorageProtocol {
    private var storedLessons: [Lesson]?
    private var storedModules: [LearningModule]?
    private var storedMetadata: ContentMetadata?
    
    func saveLessons(_ lessons: [Lesson]) {
        storedLessons = lessons
    }
    
    func saveModules(_ modules: [LearningModule]) {
        storedModules = modules
    }
    
    func saveMetadata(_ metadata: ContentMetadata) {
        storedMetadata = metadata
    }
    
    func loadLessons() -> [Lesson]? {
        return storedLessons
    }
    
    func loadModules() -> [LearningModule]? {
        return storedModules
    }
    
    func loadMetadata() -> ContentMetadata? {
        return storedMetadata
    }
}

// MARK: - ContentRepository Tests

final class ContentRepositoryTests: XCTestCase {
    var fetcher: MockContentFetcher!
    var storage: MockContentStorage!
    
    override func setUp() {
        super.setUp()
        fetcher = MockContentFetcher()
        storage = MockContentStorage()
    }
    
    override func tearDown() {
        fetcher = nil
        storage = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    func testFetchLessonById() {
        let lesson = Lesson(metadata: LessonMetadata(id: "sample_lesson", title: "Sample Lesson", description: "Description", tags: ["swift"]),
                            sections: [], questions: [])
        storage.saveLessons([lesson])
        
        // Initialize repository after setting up storage
        let repository = ContentRepository(fetcher: fetcher, storage: storage)
        
        XCTAssertEqual(repository.fetchLesson(by: "sample_lesson")?.metadata.id, "sample_lesson")
    }
    
    func testFetchModuleById() {
        let module = LearningModule(title: "Sample Module", description: "Description", subModules: [], lessons: [])
        storage.saveModules([module])
        
        // Initialize repository after setting up storage
        let repository = ContentRepository(fetcher: fetcher, storage: storage)
        
        XCTAssertEqual(repository.fetchModule(by: "sample_module")?.id, "sample_module")
    }
    
    func testUpdateDataIfNeededWithStaleData() {
        // Set stale metadata in storage and newer metadata in fetcher
        storage.saveMetadata(ContentMetadata(lastUpdatedTimestamp: 1000))
        fetcher.mockMetadata = ContentMetadata(lastUpdatedTimestamp: 2000)
        fetcher.mockLessons = [Lesson(metadata: LessonMetadata(id: "new_lesson", title: "New Lesson", description: "New Description", tags: ["swift"]), sections: [], questions: [])]
        fetcher.mockModules = [LearningModule(title: "New Module", description: "New Description", subModules: [], lessons: [])]
        
        // Initialize repository after setting up storage and fetcher
        let repository = ContentRepository(fetcher: fetcher, storage: storage)
        
        let expectation = XCTestExpectation(description: "Data should be updated")
        repository.updateDataIfNeeded { updated in
            XCTAssertTrue(updated, "Expected data to be updated")
            XCTAssertEqual(self.storage.loadLessons()?.first?.metadata.id, "new_lesson")
            XCTAssertEqual(self.storage.loadModules()?.first?.id, "new_module")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateDataIfNeededWithCurrentData() {
        // Set current metadata in storage and fetcher
        let metadata = ContentMetadata(lastUpdatedTimestamp: 2000)
        storage.saveMetadata(metadata)
        fetcher.mockMetadata = metadata
        
        // Initialize repository after setting up storage and fetcher
        let repository = ContentRepository(fetcher: fetcher, storage: storage)
        
        let expectation = XCTestExpectation(description: "Data should not be updated")
        repository.updateDataIfNeeded { updated in
            XCTAssertFalse(updated, "Expected data not to be updated")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

