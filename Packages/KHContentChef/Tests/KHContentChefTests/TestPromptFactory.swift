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

    func testGenerateTopicPrompt() throws {
        // Given
        let title = "Concurrency in Swift (and iOS Development)"
        let focus = "Comprehensive guide on concurrency in Swift and iOS development, including foundational concepts, advanced techniques, and practical applications, tailored for technical interview preparation for a Senior iOS Developer role."
        let promptType = PromptType.topic(title: title, focus: focus)

        // When
        let prompt = try PromptFactory.generatePrompt(for: promptType)
        print("*** Prompt ***\n")
        print("\(prompt)")
        print("\n*** Prompt ***")

        // Then
        XCTAssertTrue(prompt.contains(title), "The generated prompt should contain the title.")
        XCTAssertTrue(prompt.contains(focus), "The generated prompt should contain the focus.")
        XCTAssertFalse(prompt.contains("{{title}}"), "The placeholder {{title}} should be replaced.")
        XCTAssertFalse(prompt.contains("{{focus}}"), "The placeholder {{focus}} should be replaced.")
    }
}
