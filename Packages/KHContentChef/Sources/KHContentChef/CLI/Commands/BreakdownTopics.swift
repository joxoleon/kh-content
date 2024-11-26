import ArgumentParser
import Foundation

struct BreakdownTopics: ParsableCommand {

    @Option(
        name: .shortAndLong,
        help: "The input file path that lists the topics to breakdown."
    )
    var inputFilePath: String = ContentLocationConstants.batchTopicGenerationInputFilePath

    @Option(
        name: .shortAndLong,
        help: "The output directory path to save the generated topic breakdowns."
    )
    var outputDirectory: String = ContentLocationConstants.topicBreakdownOutputDir

    func run() throws {
        print(
            "Running topic breakdown with input file: \(inputFilePath) and output directory: \(outputDirectory)"
        )

        // Create a semaphore
        let semaphore = DispatchSemaphore(value: 0)

        // Run the async function in a Task
        Task {
            do {
                let service = TopicBreakdownService()
                try await service.generateTopicBreakdowns(
                    inputFilePath: URL(fileURLWithPath: inputFilePath),
                    outputDirectory: URL(fileURLWithPath: outputDirectory))
                semaphore.signal()
            } catch {
                print("Error: \(error)")
                semaphore.signal()
            }
        }

        // Wait for the async task to complete
        semaphore.wait()
        print("Topic breakdown generation finished!")
    }
}
