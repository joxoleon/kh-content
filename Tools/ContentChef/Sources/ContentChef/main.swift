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
        try parseLessons(
            from: URL(fileURLWithPath: contentPath), 
            to: URL(fileURLWithPath: outputPath)
        )
    }

    // MARK: - Lesson Parsing

    func parseLessons(from contentDirectory: URL, to outputDirectory: URL) throws {
        // Parse lessons
        let lessonPath = contentDirectory.appendingPathComponent("Lessons")
        let parser = LessonParser()
        let lessons = try parser.parseLessons(in: lessonPath)

        // Save lesson array to JSON
        let outputURL = outputDirectory.appendingPathComponent("lessons.json")
        createFileIfNotExists(atPath: outputURL.path)
        let jsonData = try JSONEncoder().encode(lessons)
        let prettyJsonData = try serializeToPrettyJSON(jsonData)
        try writeJSONData(prettyJsonData, to: outputURL)

        // Save metadata array to JSON
        let metadataOutputURL = outputDirectory.appendingPathComponent("lesson_metadata.json")
        createFileIfNotExists(atPath: metadataOutputURL.path)
        let metadata = lessons.map { $0.metadata }
        let metadataJSONData = try JSONEncoder().encode(metadata)
        let prettyMetadataJSONData = try serializeToPrettyJSON(metadataJSONData)
        try writeJSONData(prettyMetadataJSONData, to: metadataOutputURL)

        print("Lessons and metadata parsed and saved successfully.")
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

        guard let dictionary = jsonObject as? [String: Any] else {
            return data
        }

        let sortedDictionary = dictionary.sorted { (lhs, rhs) -> Bool in
            let order: [String: Int] = [
                "metadata": 0,
                "Sections": 1,
                "Questions": 3
            ]
            let lhsOrder = order[lhs.key] ?? 2
            let rhsOrder = order[rhs.key] ?? 2
            return lhsOrder < rhsOrder
        }

        let sortedJsonObject = Dictionary(uniqueKeysWithValues: sortedDictionary)

        return try JSONSerialization.data(
            withJSONObject: sortedJsonObject, options: .prettyPrinted)
    }
}

// Instead of `@main`, manually call `ContentChef.main()`
ContentChef.main()