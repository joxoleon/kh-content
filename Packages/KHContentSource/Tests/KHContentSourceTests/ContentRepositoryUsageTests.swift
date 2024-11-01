import XCTest
@testable import KHContentSource

final class ContentRepositoryUsageTests: XCTestCase {
    
    func testContentRepositoryUsage() async throws {
        let fetcher = GitHubContentFetcher()
        let storage = FileContentStorage()
        let repository = ContentRepository(fetcher: fetcher, storage: storage)
        
        do {
            let updated = try await repository.updateDataIfNeeded()
            if updated {
                print("Data was updated from the remote source.")
            } else {
                print("Local data is up-to-date.")
            }

            // Fetch lesson catalog and all lessons and make sure they match and they aren't empty
            let lessonIds = repository.fetchLessonIdCatalog()
            let all_lessons = repository.fetchLessons(by: lessonIds)
            XCTAssertEqual(all_lessons.count, lessonIds.count)
            XCTAssertFalse(all_lessons.isEmpty)

            // Fetch module catalog and all modules and make sure they match and they aren't empty
            let moduleIds = repository.fetchModuleIdCatalog()
            let all_modules = repository.fetchModules(by: moduleIds)
            XCTAssertEqual(all_modules.count, moduleIds.count)
            XCTAssertFalse(all_modules.isEmpty)
            
        } catch {
            XCTFail("An error occurred: \(error)")
        }
    }
}
