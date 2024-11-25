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

        // Load the config file
        let config = try LessonGenerationConfig.load(from: URL(fileURLWithPath: configPath))

        // Create a semaphore
        let semaphore = DispatchSemaphore(value: 0)

        // Run the async function in a Task
        Task {
            do {
                try await generateLesson(config: config)
                semaphore.signal()
            } catch {
                print("Error: \(error)")
                semaphore.signal()
            }
        }

        // Wait for the async task to complete
        semaphore.wait()
    }

    // MARK: - Private Methods

    private func generateLesson(config: LessonGenerationConfig) async throws {
        let service = LessonGenerationService(config: config)
        let _ = try await service.generateLesson(input: LessonGenerationInput(title: title, description: focus))
    }


}
