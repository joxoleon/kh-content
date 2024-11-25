import XCTest
@testable import KHContentChef

final class TestPromptFactory: XCTestCase {

    func testGenerateLessonPrompt() throws {
        // Given
        let title = "Advanced Swift Concurrency"
        let focus = "An in-depth look at the new concurrency features in Swift 5.5."
        let promptType = PromptType.lesson(title: title, focus: focus)

        // When
        let prompt = try PromptFactory.generatePrompt(for: promptType)
        // print("Generated Prompt:\n\(prompt)")

        // Then
        XCTAssertTrue(prompt.contains(title), "The generated prompt should contain the title.")
        XCTAssertTrue(prompt.contains(focus), "The generated prompt should contain the focus.")
        XCTAssertFalse(prompt.contains("{{title}}"), "The placeholder {{title}} should be replaced.")
        XCTAssertFalse(prompt.contains("{{focus}}"), "The placeholder {{focus}} should be replaced.")
    }
}
