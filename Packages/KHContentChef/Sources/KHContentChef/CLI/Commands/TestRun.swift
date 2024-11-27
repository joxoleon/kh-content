import ArgumentParser
import Foundation

struct TestRun: ParsableCommand {
    func run() throws {
        breakdownSingleTopic()
    }
}

private func breakdownSingleTopic() {
    let semaphore = DispatchSemaphore(value: 0)

    // Run the async function in a Task
    Task {
        do {
            let topicBreakdownInput = TopicBreakdownInput(
                title: "Database Modeling and Design in SQLite",
                description:
                    "A practical guide to designing and modeling databases in SQLite, including schema design, normalization, relationships, indexing, and best practices for optimizing performance in mobile applications"
            )
            let topicBreakdownSavePath = URL(fileURLWithPath: ContentLocationConstants.topicBreakdownOutputDir).appendingPathComponent(topicBreakdownInput.filename)
            
            let service = TopicBreakdownService()
            printGreen("Generating topic breakdown for \(topicBreakdownInput.title)")

            let topicBreakdown = try await service.generateTopicBreakdown(input: topicBreakdownInput)
            
            printGreen("Topic breakdown for \(topicBreakdownInput.title) generated successfully")

            try topicBreakdown.save(to: topicBreakdownSavePath)
            printGreen("Topic breakdown for \(topicBreakdownInput.title) saved to \(topicBreakdownSavePath.path)")
            semaphore.signal()
        } catch {
            print("Error: \(error)")
            
            semaphore.signal()
        }
    }

    // Wait for the async task to complete
    semaphore.wait()
}
