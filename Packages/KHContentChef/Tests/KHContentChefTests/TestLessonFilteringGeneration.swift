import Foundation
import XCTest
@testable import KHContentChef
import KHContentSource

final class AlreadyGeneratedLessonFilteringTests: XCTestCase {
    
    func testFilterAlreadyGeneratedLessons() async throws {
        //Given
        let batchInput = try BatchLessonGenerationInput.load(from: ContentLocationConstants.batchLessonGenerationInputFilePath)

        //When
        let filteredBatchInput = batchInput.filterAlreadyGeneratedLessons()

        //Then
        XCTAssertEqual(filteredBatchInput.lessons.count, 0)

    }
    
    func testSanitizeString() {
        //Given
        let input = "Grand Central Dispatch (GCD): Basics"
        let expectedOutput = "grand_central_dispatch_gcd_basics"

        //When
        let output = sanitizeString(input)
        print("Output: \(output)")

        //Then
        XCTAssertEqual(output, expectedOutput)
    }
}
