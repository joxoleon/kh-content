import Foundation

// MARK: - Constants

public enum ContentLocationConstants {
    // Directories
    static var contentDir: String { return "/Users/jovanradivojsa/Desktop/workspace/ios/kh-content/Content" }
    static var configDir: String { return "\(contentDir)/Config" }
    static var lessonRawContentDir: String { return "\(contentDir)/Input/iOS/Lessons" }
    static var moduleRawContentDir: String { return "\(contentDir)/Input/iOS/Modules" }
    static var topicBreakdownOutputDir: String { return "\(contentDir)/Input/iOS/Topics/BrokenDownTopics" }

    // Files
    static let lessonGenerationConfigFilePath = "\(configDir)/lesson_generation_config.json"
    static let rawLessonGeneratedContentListFilePath = "\(lessonRawContentDir)/lesson_content_list.json"
    static let batchLessonGenerationInputFilePath = "\(contentDir)/Input/Temp/batch_generate_lessons.json"
    static let batchTopicGenerationInputFilePath = "\(contentDir)/Input/iOS/GenerationInput/topic_generation_input.json"
}

// MARK: - FILE MANAGER UTILITY

enum FileManagerUtility {
    static func moveItemOverwrite(from sourceURL: URL, to destinationURL: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.moveItem(at: sourceURL, to: destinationURL)
    }
}

// MARK: - Utility Implementations

enum KHContentFileUtility {
    static func updateLessonGeneratedContentList() throws {
        // Read all .md files from the lessonRawContentDir and extract only their filenames
        let fileManager = FileManager.default
        let lessonFileURLs = try fileManager.contentsOfDirectory(atPath: ContentLocationConstants.lessonRawContentDir)
            .filter { $0.hasSuffix(".md") }
            .map { URL(fileURLWithPath: $0).lastPathComponent }
        let lessonFileNames = lessonFileURLs.map { $0.replacingOccurrences(of: ".md", with: "") }

        // Create a LessonGeneratedContentList object and save it to the rawLessonGeneratedContentListFilePath
        let lessonGeneratedContentList = LessonGeneratedContentList(lessonFileNames: lessonFileNames)
        try lessonGeneratedContentList.save(to: URL(fileURLWithPath: ContentLocationConstants.rawLessonGeneratedContentListFilePath))

    }

    static func fetchLessonGeneratedContentList() throws -> LessonGeneratedContentList {
        return try LessonGeneratedContentList.load(from: ContentLocationConstants.rawLessonGeneratedContentListFilePath)
    }
}


// MARK: - Utility Protocols

public protocol FilePersistable {
    static func load(from url: URL) throws -> Self
    static func load(from path: String) throws -> Self
    func save(to url: URL) throws
}

public extension FilePersistable where Self: Decodable {
    static func load(from path: String) throws -> Self {
        let url = URL(fileURLWithPath: path)
        return try load(from: url)
    }

    static func load(from url: URL) throws -> Self {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }

    func save(to url: URL) throws where Self: Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: url)
    }
    
}
