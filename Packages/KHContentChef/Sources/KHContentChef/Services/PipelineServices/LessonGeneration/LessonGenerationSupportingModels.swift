import Foundation

struct LessonGenerationInput: Codable {
    let title: String
    let description: String
}

struct BatchLessonGenerationInput: Codable {
    let lessons: [LessonGenerationInput]

    static func load(from url: URL) throws -> BatchLessonGenerationInput {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(BatchLessonGenerationInput.self, from: data)
    }
}

struct LessonGenerationConfig: Codable {
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

    static func load(from url: URL) throws -> LessonGenerationConfig {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(LessonGenerationConfig.self, from: data)
    }
}
