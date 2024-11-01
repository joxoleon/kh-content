import XCTest
@testable import KHContentSource

// MARK: - Mocks for Testing

class MockContentFetcher: ContentFetcherProtocol {
    var mockMetadata: ContentMetadata?
    var mockLessons: [Lesson] = []
    var mockModules: [LearningModule] = []
    
    func fetchContentMetadata() async throws -> ContentMetadata {
        if let metadata = mockMetadata {
            return metadata
        } else {
            throw NSError(domain: "Test", code: -1, userInfo: nil)
        }
    }
    
    func fetchLessons() async throws -> [Lesson] {
        return mockLessons
    }
    
    func fetchModules() async throws -> [LearningModule] {
        return mockModules
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
        let lesson = Lesson(metadata: LessonMetadata(title: "Sample Lesson", description: "Description", tags: ["swift"]),
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
    
    func testUpdateDataIfNeededWithStaleData() async {
        // Set stale metadata in storage and newer metadata in fetcher
        storage.saveMetadata(ContentMetadata(lastUpdatedTimestamp: 1000))
        fetcher.mockMetadata = ContentMetadata(lastUpdatedTimestamp: 2000)
        fetcher.mockLessons = [Lesson(metadata: LessonMetadata(title: "New Lesson", description: "New Description", tags: ["swift"]), sections: [], questions: [])]
        fetcher.mockModules = [LearningModule(title: "New Module", description: "New Description", subModules: [], lessons: [])]
        
        // Initialize repository after setting up storage and fetcher
        let repository = ContentRepository(fetcher: fetcher, storage: storage)
        
        do {
            let updated = try await repository.updateDataIfNeeded()
            XCTAssertTrue(updated, "Expected data to be updated")
            XCTAssertEqual(self.storage.loadLessons()?.first?.metadata.id, "new_lesson")
            XCTAssertEqual(self.storage.loadModules()?.first?.id, "new_module")
        } catch {
            XCTFail("Update data failed with error: \(error)")
        }
    }
    
    func testUpdateDataIfNeededWithCurrentData() async {
        // Set current metadata in storage and fetcher
        let metadata = ContentMetadata(lastUpdatedTimestamp: 2000)
        storage.saveMetadata(metadata)
        fetcher.mockMetadata = metadata
        
        // Initialize repository after setting up storage and fetcher
        let repository = ContentRepository(fetcher: fetcher, storage: storage)
        
        do {
            let updated = try await repository.updateDataIfNeeded()
            XCTAssertFalse(updated, "Expected data not to be updated")
        } catch {
            XCTFail("Update data failed with error: \(error)")
        }
    }
}

