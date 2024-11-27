import ArgumentParser
import Foundation
import Yams
import KHContentSource

struct BuildTopLevelModule: ParsableCommand {

    @Option(name: .shortAndLong, help: "The file path for the topic breakdown input file.")
    var batchTopicBreakdownInputFilePath: String = ContentLocationConstants.batchTopicGenerationInputFilePath

    @Option(name: .long, help: "The directory where all of the broken down topics files are stored.")
    var topicBreakdownOutputDir: String = ContentLocationConstants.topicBreakdownOutputDir

    @Option(name: .long, help: "The file path where the top level module will be generated.")
    var topLevelModuleYamlFilePath: String = ContentLocationConstants.topLevelModuleYamlFilePath   
    
    func run() throws {
        // Load all topics files from the topic breakdown output directory
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: topicBreakdownOutputDir) else {
            printRed("Failed to load topic breakdown output files from directory: \(topicBreakdownOutputDir)")
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
                printRed("Failed to load topic breakdown output file: \(file)")
            }
        }

        // Load the batch topic generation input file
        print("Loading batch topic generation input file from: \(batchTopicBreakdownInputFilePath)")
        let batchTopicBreakdownInput = try BatchTopicBreakdownInput.load(from: URL(fileURLWithPath: batchTopicBreakdownInputFilePath))

        // Order the topicBreakdownOutputs by the order in the batchTopicBreakdownInput
        let orderedTopicBreakdownOutputs = batchTopicBreakdownInput.topics.compactMap { topic in
            topicBreakdownOutputs.first { $0.title == topic.title }
        }

        // Create the top level module
        let topLevelModule = TopLevelModuleSerialization.TopLevelModule(
            title: "iOS Interview Preparation Course",
            description: "Comprehensive preparation course for Senior iOS Developer interviews, covering advanced Swift concepts, iOS architectures, design patterns, concurrency, testing, and key principles needed to excel in technical interviews at top-tier companies.",
            topicBreakdownOutputs: orderedTopicBreakdownOutputs
        )

        // Save the top level module to the specified file path
        try topLevelModule.save(to: URL(fileURLWithPath: topLevelModuleYamlFilePath))
        print("Top level module saved to: \(topLevelModuleYamlFilePath)")

        // Test top level module deserialization
        let moduleParser = LearningModuleParser()
        if let _ = try? moduleParser.parseLearningModule(from: URL(fileURLWithPath: topLevelModuleYamlFilePath)) {
            printGreen("Top level module deserialized successfully:")
        } else {
            printRed("Failed to deserialize top level module")
        }

        printGreen("Top level module generation completed successfully")
        printGreen("File saved to: \(topLevelModuleYamlFilePath)")
    }
}

enum TopLevelModuleSerialization {
    struct TopLevelModule: Codable {
        let title: String
        let description: String
        let subModules: [SubModule]

        init(title: String, description: String, topicBreakdownOutputs: [TopicBreakdownOutput]) {
            self.title = title
            self.description = description
            self.subModules = topicBreakdownOutputs.map { SubModule(topicBreakdownOutput: $0) }
        }

        /// Saves the module structure to a YAML file at the specified path
        func save(to filePath: URL) throws {
            // Serialize the `TopLevelModule` to YAML
            let yamlString = try YAMLEncoder().encode(self)
            
            // Write the YAML string to the specified file path, overwriting if it exists
            try yamlString.write(to: filePath, atomically: true, encoding: .utf8)
        }
    }

    struct SubModule: Codable {
        let title: String
        let description: String
        let lessons: [String]?
        let subModules: [SubModule]?

        init(topicBreakdownOutput: TopicBreakdownOutput) {
            self.title = topicBreakdownOutput.title
            self.description = topicBreakdownOutput.description
            self.lessons = topicBreakdownOutput.batchLessonGenerationInput.lessons.map { $0.filename }
            // Intentionally nil because we won't have submodules for this type of module creation
            self.subModules = nil
        }
    }
}