import ArgumentParser
import Foundation

struct GenerateLessons: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Generates lessons from an input file."
    )

    @Option(name: .shortAndLong, help: "The config file path used for the LessonGenerationService.")
    var configPath: String = "/Users/jovanradivojsa/Desktop/workspace/ios/kh-content/Content/Config/lesson_generation_config.json"

    @Option(name: .shortAndLong, help: "The batch input file path that lists the lessons to generate.")
    var batchInputFile: String = "/Users/jovanradivojsa/Desktop/workspace/ios/kh-content/Content/Input/Temp/batch_generate_lessons.json"

    func run() throws {

        // Load the config file
        print("Loading config file from: \(configPath)")
        let config = try LessonGenerationConfig.load(from: URL(fileURLWithPath: configPath))
        print("Loading batch input file from: \(batchInputFile)")
        let batchInput = try BatchLessonGenerationInput.load(from: URL(fileURLWithPath: batchInputFile))

        // Create a semaphore
        let semaphore = DispatchSemaphore(value: 0)

        // Run the async function in a Task
        Task {
            do {
                let service = LessonGenerationService(config: config)
                let _ = try await service.generateLessons(batchInput: batchInput)
                semaphore.signal()
            } catch {
                print("Error: \(error)")
                semaphore.signal()
            }
        }

        // Wait for the async task to complete
        semaphore.wait()
    }
}
