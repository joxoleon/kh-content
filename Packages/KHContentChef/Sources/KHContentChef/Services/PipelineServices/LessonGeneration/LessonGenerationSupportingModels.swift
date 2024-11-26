import Foundation
import KHContentSource

struct LessonGeneratedContentList: Codable, FilePersistable {
    let lessonFileNames: [String]
}

struct LessonGenerationInput: Codable {
    let title: String
    let description: String
    var filename: String {
        return sanitizeString(title)
    }
}

struct BatchLessonGenerationInput: Codable, FilePersistable {
    let lessons: [LessonGenerationInput]
}

struct LessonGenerationConfig: Codable, FilePersistable {
    let temporaryDirectory: URL
    let outputDirectory: URL
    let model: String
    let temperature: Double
    let maxTokens: Int  // When using batch requests, this represents the max tokens per prompt

    init(
        temporaryDirectory: URL = URL(fileURLWithPath: "/var/tmp/contentChef"),
        outputDirectory: URL = URL(fileURLWithPath: "/Users/jovanradivojsa/Desktop/workspace/ios/kh-content/Content/Input/iOS/Lessons"),
        model: String = "gpt-4",
        temperature: Double = 0.7,
        maxTokens: Int = 1000
    ) {
        self.temporaryDirectory = temporaryDirectory
        self.outputDirectory = outputDirectory
        self.model = model
        self.temperature = temperature
        self.maxTokens = maxTokens
    }

    enum CodingKeys: String, CodingKey {
        case temporaryDirectory
        case outputDirectory
        case model
        case temperature
        case maxTokens
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let temporaryDirectoryString = try container.decode(String.self, forKey: .temporaryDirectory)
        let outputDirectoryString = try container.decode(String.self, forKey: .outputDirectory)
        self.temporaryDirectory = URL(fileURLWithPath: temporaryDirectoryString)
        self.outputDirectory = URL(fileURLWithPath: outputDirectoryString)
        self.model = try container.decode(String.self, forKey: .model)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
        self.maxTokens = try container.decode(Int.self, forKey: .maxTokens)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(temporaryDirectory.path, forKey: .temporaryDirectory)
        try container.encode(outputDirectory.path, forKey: .outputDirectory)
        try container.encode(model, forKey: .model)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(maxTokens, forKey: .maxTokens)
    }
}
