import ArgumentParser
import Foundation

struct ContentChef: ParsableCommand {
    @Argument(help: "The root path of the content directory.")
    var contentPath: String

    @Option(name: .shortAndLong, help: "The output path for generated JSON files.")
    var outputPath: String

    func run() throws {
        print("Running ContentChef...")

        // Parse lessons
        try parse(
            from: URL(fileURLWithPath: contentPath), 
            to: URL(fileURLWithPath: outputPath)
        )
    }

    // MARK: - Parsing

    func parse(from contentDirectory: URL, to outputDirectory: URL) throws {
        print("Parsing files from input directory \(contentDirectory.path)")

        // MARK: - Lessons

        // Parse lessons
        let lessonPath = contentDirectory.appendingPathComponent("Lessons")
        let parser = LessonParser()
        let lessons = try parser.parseLessons(in: lessonPath)

        // Save lesson array to JSON
        let outputURL = outputDirectory.appendingPathComponent("all_lessons.json")
        createFileIfNotExists(atPath: outputURL.path)
        let jsonData = try JSONEncoder().encode(lessons)
        let prettyJsonData = try serializeToPrettyJSON(jsonData)
        try writeJSONData(prettyJsonData, to: outputURL)

        // Save metadata array to JSON
        let metadataOutputURL = outputDirectory.appendingPathComponent("all_lesson_metadata.json")
        createFileIfNotExists(atPath: metadataOutputURL.path)
        let metadata = lessons.map { $0.metadata }
        let metadataJSONData = try JSONEncoder().encode(metadata)
        let prettyMetadataJSONData = try serializeToPrettyJSON(metadataJSONData)
        try writeJSONData(prettyMetadataJSONData, to: metadataOutputURL)

        // Save single lesson files to JSON
        for lesson in lessons {
            let lessonOutputURL = outputDirectory.appendingPathComponent("Lessons").appendingPathComponent("\(lesson.metadata.id).json")
            createFileIfNotExists(atPath: lessonOutputURL.path)
            let lessonData = try JSONEncoder().encode(lesson)
            let prettyLessonData = try serializeToPrettyJSON(lessonData)
            try writeJSONData(prettyLessonData, to: lessonOutputURL)
        }

        // MARK: - Modules

        // Parse modules
        let modulePath = contentDirectory.appendingPathComponent("Modules")
        let moduleParser = LearningModuleParser()
        let modules = try moduleParser.parseModules(in: modulePath)

        // Save module array to JSON
        let moduleOutputURL = outputDirectory.appendingPathComponent("all_modules.json")
        createFileIfNotExists(atPath: moduleOutputURL.path)
        let moduleJSONData = try JSONEncoder().encode(modules)
        let prettyModuleJSONData = try serializeToPrettyJSON(moduleJSONData)
        try writeJSONData(prettyModuleJSONData, to: moduleOutputURL)

        // Save single module files to JSON
        for module in modules {
            let moduleOutputURL = outputDirectory.appendingPathComponent("Modules").appendingPathComponent("\(module.id).json")
            createFileIfNotExists(atPath: moduleOutputURL.path)
            let moduleData = try JSONEncoder().encode(module)
            let prettyModuleData = try serializeToPrettyJSON(moduleData)
            try writeJSONData(prettyModuleData, to: moduleOutputURL)
        }

        // MARK: - Content Metadata

        // Create content metadata struct and save to JSON
        let contentMetadata = Parsing.ContentMetadata(lastUpdatedTimestamp: Date().timeIntervalSince1970)
        let contentMetadataPath = contentDirectory.appendingPathComponent("content_metadata.json")
        createFileIfNotExists(atPath: contentMetadataPath.path)
        let contentMetadataData = try JSONEncoder().encode(contentMetadata)
        let prettyContentMetadataData = try serializeToPrettyJSON(contentMetadataData)
        try writeJSONData(prettyContentMetadataData, to: contentMetadataPath)

        print("Lessons, Modules, and Metadata parsed successfully and stored in \(outputDirectory.path)")
    }

    // MARK: - Utility Functions

    func createFileIfNotExists(atPath path: String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        }
    }

    func writeJSONData(_ data: Data, to url: URL) throws {
        try data.write(to: url)
    }

    func serializeToPrettyJSON(_ data: Data) throws -> Data {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
    }
}

// Instead of `@main`, manually call `ContentChef.main()`
ContentChef.main()