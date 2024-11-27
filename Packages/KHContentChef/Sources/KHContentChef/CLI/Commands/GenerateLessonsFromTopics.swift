import ArgumentParser
import Foundation

struct GenerateLessonsFromTopics: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Generates lessons from an input file."
    )

    @Option(name: .shortAndLong, help: "The config file path used for the LessonGenerationService.")
    var configPath: String = ContentLocationConstants.lessonGenerationConfigFilePath

    @Option(name: .shortAndLong, help: "The directory where all of the broken down topics files are stored.")
    var topicBreakdownOutputDir: String = ContentLocationConstants.topicBreakdownOutputDir

    func run() throws {

        // Load the config file
        print("Loading config file from: \(configPath)")
        let config = try LessonGenerationConfig.load(from: URL(fileURLWithPath: configPath))

        // Load all topics files from the topic breakdown output directory
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: topicBreakdownOutputDir) else {
            throw PromptFactoryError.failedToLoadTemplates("Could not read files in directory \(topicBreakdownOutputDir)")
        }

        // Load an array of topic breakdown outputs
        var topicBreakdownOutputs: [TopicBreakdownOutput] = []
        for file in files {
            let fileURL = URL(fileURLWithPath: topicBreakdownOutputDir).appendingPathComponent(file)
            guard file.hasSuffix(".json") else { continue } // Only load json files
            do {
                let topicBreakdownOutput = try TopicBreakdownOutput.load(from: fileURL)
                topicBreakdownOutputs.append(topicBreakdownOutput)
            } catch {
                print("Failed to load topic breakdown output file: \(file)")
            }
        }
                
        for topicBreakdownOutput in topicBreakdownOutputs {
            // Create a semaphore
            let semaphore = DispatchSemaphore(value: 0)

            printWithBorder("Generating lessons for \(topicBreakdownOutput.title)")

            // Run the async function in a Task
            Task {
                do {
                    let service = LessonGenerationService(config: config)
                    let _ = try await service.generateLessons(batchInput: topicBreakdownOutput.batchLessonGenerationInput)
                    semaphore.signal()
                } catch {
                    print("Error: \(error)")
                    semaphore.signal()
                }
            }

            // Wait for the async task to complete
            semaphore.wait()
            printGreen("Lessons generated for \(topicBreakdownOutput.title)")
        }

        printGreen("************************************************************************")
        printGreen("Lessons generated successfully")
        printGreen("************************************************************************")
    }
}

fileprivate func printWithBorder(_ text: String) {
    print("************************************************************************")
    print(text)
    print("************************************************************************")
}
