import XCTest
@testable import ContentChef

final class FileContentStorageTests: XCTestCase {
    
    var contentStorage: FileContentStorage!
    let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("FileContentStorageTests")
    
    override func setUp() {
        super.setUp()
        
        // Ensure the test directory exists
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true, attributes: nil)
        
        // Configure storage to use the test directory
        contentStorage = FileContentStorage(baseDirectory: testDirectory)
    }
    
    override func tearDown() {
        // Clean up test files after each test
        try? FileManager.default.removeItem(at: testDirectory)
        super.tearDown()
    }
    
    // MARK: - Metadata Tests

    func testSaveAndLoadMetadata() {
        let sampleMetadata = ContentMetadata(lastUpdatedTimestamp: Date().timeIntervalSince1970)
        contentStorage.saveMetadata(sampleMetadata)
        
        let loadedMetadata = contentStorage.loadMetadata()
        XCTAssertEqual(loadedMetadata?.lastUpdatedTimestamp, sampleMetadata.lastUpdatedTimestamp, "Failed to load saved metadata.")
    }

    // MARK: - Lesson Tests

    func testSaveAndLoadLessons() {
        let sampleLesson = Lesson(metadata: LessonMetadata(id: "lesson1", title: "Sample Lesson", description: "Test Description", tags: ["swift", "ios"]),
                                  sections: [LessionContentSection(title: "Section 1", content: "Content")],
                                  questions: [Question(id: "q1", type: "MCQ", proficiency: "beginner", question: "Test question?", answers: ["A", "B", "C"], correctAnswerIndex: 0, explanation: "Explanation")])
        
        contentStorage.saveLessons([sampleLesson])
        
        let loadedLessons = contentStorage.loadLessons()
        XCTAssertEqual(loadedLessons?.count, 1, "Lesson count mismatch after saving.")
        XCTAssertEqual(loadedLessons?.first?.metadata.id, sampleLesson.metadata.id, "Failed to load saved lesson.")
    }

    // MARK: - Module Tests

    func testSaveAndLoadModules() {
        let sampleModule = LearningModule(title: "Sample Module", description: "Test Description", lessons: ["lesson1"])
        contentStorage.saveModules([sampleModule])
        
        let loadedModules = contentStorage.loadModules()
        XCTAssertEqual(loadedModules?.count, 1, "Module count mismatch after saving.")
        XCTAssertEqual(loadedModules?.first?.id, sampleModule.id, "Failed to load saved module.")
    }
}
