import ArgumentParser
import Foundation
import KHContentSource

struct PublishContent: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Parses and publishes content from a directory."
    )

    @Argument(help: "The root path of the content directory.")
    var contentPath: String

    @Option(name: .shortAndLong, help: "The output path for generated JSON files.")
    var outputPath: String

    private let fileManager: FileManager = .default

    func run() throws {
        print("Running PublishContent...")

        let contentDirectory = URL(fileURLWithPath: contentPath)
        let outputDirectory = URL(fileURLWithPath: outputPath)

        // Ensure output directories exist
        try ensureDirectoryStructure(outputDirectory)

        // Step-by-step processing
        let lessons = try parseLessons(from: contentDirectory)
        try saveLessons(lessons, to: outputDirectory)

        let modules = try parseModules(from: contentDirectory)
        try saveModules(modules, to: outputDirectory)

        try saveContentMetadata(to: outputDirectory)

        print("PublishContent completed successfully! All files saved to \(outputDirectory.path)")
    }

    // MARK: - Flow Methods

    private func ensureDirectoryStructure(_ outputDirectory: URL) throws {
        try CLIUtility.ensureDirectoryExists(outputDirectory.appendingPathComponent("Lessons"))
        try CLIUtility.ensureDirectoryExists(outputDirectory.appendingPathComponent("Modules"))
    }

    private func parseLessons(from contentDirectory: URL) throws -> [Lesson] {
        print("Parsing lessons...")
        let lessonPath = contentDirectory.appendingPathComponent("Lessons")
        let parser = LessonParser()
        let lessons = try parser.parseLessons(in: lessonPath)
        print("Lessons parsed successfully.")
        return lessons
    }

    private func saveLessons(_ lessons: [Lesson], to outputDirectory: URL) throws {
        print("Saving lessons to JSON...")

        // Save all lessons JSON
        try CLIUtility.saveJSON(lessons, to: outputDirectory.appendingPathComponent("all_lessons.json"))

        // Save lesson metadata
        let metadata = lessons.map { $0.metadata }
        try CLIUtility.saveJSON(metadata, to: outputDirectory.appendingPathComponent("all_lesson_metadata.json"))

        // Save individual lessons
        let lessonDir = outputDirectory.appendingPathComponent("Lessons")
        for lesson in lessons {
            try CLIUtility.saveJSON(lesson, to: lessonDir.appendingPathComponent("\(lesson.metadata.id).json"))
        }
        print("Lessons saved successfully.")
    }

    private func parseModules(from contentDirectory: URL) throws -> [LearningModule] {
        print("Parsing modules...")
        let modulePath = contentDirectory.appendingPathComponent("Modules")
        let parser = LearningModuleParser()
        let modules = try parser.parseModules(in: modulePath)
        print("Modules parsed successfully.")
        return modules
    }

    private func saveModules(_ modules: [LearningModule], to outputDirectory: URL) throws {
        print("Saving modules to JSON...")

        // Save all modules JSON
        try CLIUtility.saveJSON(modules, to: outputDirectory.appendingPathComponent("all_modules.json"))

        // Save individual modules
        let moduleDir = outputDirectory.appendingPathComponent("Modules")
        for module in modules {
            try CLIUtility.saveJSON(module, to: moduleDir.appendingPathComponent("\(module.id).json"))
        }
        print("Modules saved successfully.")
    }

    private func saveContentMetadata(to outputDirectory: URL) throws {
        print("Saving content metadata...")
        let metadata = ContentMetadata(lastUpdatedTimestamp: Date().timeIntervalSince1970)
        try CLIUtility.saveJSON(metadata, to: outputDirectory.appendingPathComponent("content_metadata.json"))
        print("Content metadata saved successfully.")
    }
}

// MARK: - CLIUtility Enum

enum CLIUtility {
    static func ensureDirectoryExists(_ directory: URL) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    static func saveJSON<T: Encodable>(_ object: T, to url: URL) throws {
        let jsonData = try JSONEncoder().encode(object)
        let prettyJsonData = try serializeToPrettyJSON(jsonData)
        try writeJSONData(prettyJsonData, to: url)
    }

    static func serializeToPrettyJSON(_ data: Data) throws -> Data {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
    }

    static func writeJSONData(_ data: Data, to url: URL) throws {
        try data.write(to: url)
    }
}
