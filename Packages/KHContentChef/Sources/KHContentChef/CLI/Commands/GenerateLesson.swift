import ArgumentParser
import Foundation

struct GenerateLesson: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Generates a single lesson from the CLI tool."
    )

    @Option(name: .shortAndLong, help: "The config file path used for the LessonGenerationService.")
    var configPath: String = "../../Content/Config/lesson_generation_config.json"

    @Option(name: .shortAndLong, help: "The title of the lesson to generate.")
    var title: String

    @Option(name: .shortAndLong, help: "The focus of the lesson to generate.")
    var focus: String

    func run() throws {

    }

    // MARK: - Private Methods

    private func generateLEsson(config: LessonGenerationConfig) async throws {
        let service = LessonGenerationService(config: config)
        let lessonFileUrl = try await service.generateLesson(input: LessonGenerationInput(title: title, description: focus))
        print("Lesson generated successfully at \(lessonFileUrl.path)")
    }


}
