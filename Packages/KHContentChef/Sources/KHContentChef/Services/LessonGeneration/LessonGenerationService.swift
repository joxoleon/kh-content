import Foundation
import KHContentSource

// MARK: - Supporting Models

struct LessonGenerationInput {
    let title: String
    let description: String
}

struct LessonGenerationConfig: Codable {
    let temporaryDirectory: URL
    let outputDirectory: URL
    let model: String
    let temperature: Double
    let maxTokens: Int  // When using batch requests, this represents the max tokens per prompt

    init(
        temporaryDirectory: URL = URL(fileURLWithPath: "/var/tmp/contentChef"),
        outputDirectory: URL = URL(fileURLWithPath: "../../Content/Input/iOS/Lessons"),
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

// MARK: - Errors

enum LessonGenerationError: Error {
    case missingPromptFile
    case invalidLesson(String)
    case apiError(String)
}

// MARK: - Service

protocol LessonGenerationServiceProtocol {
    func generateLesson(input: LessonGenerationInput) async throws -> URL
    // func generateLessons(inputs: [LessonGenerationInput], progress: ((Double) -> Void)?) async throws -> [URL]
}

final class LessonGenerationService: LessonGenerationServiceProtocol {

    // MARK: - Properties

    private let apiService: OpenAIAPIProtocol
    private let parser: LessonParser
    private let config: LessonGenerationConfig

    // MARK: - Initializers

    init(
        apiService: OpenAIAPIProtocol = OpenAIAPIService(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!), // Intentionally force unwrapped
        parser: LessonParser = LessonParser(),
        config: LessonGenerationConfig = LessonGenerationConfig()
    ) {
        self.apiService = apiService
        self.parser = parser
        self.config = config
    }

    // MARK: - Public Methods

    func generateLesson(input: LessonGenerationInput) async throws -> URL {
        
        printGreen("Generating lesson with title: \(input.title) and focus: \(input.description)")
        // Prepare prompt - Factory is not injected and I don't give a fuck
        let prompt = try PromptFactory.generatePrompt(for: .lesson(title: input.title, focus: input.description))

        printGreen("Sending request to OpenAI")
        let spinner = Spinner()
        spinner.start()
        // Send API request
        let response = try await apiService.sendPrompt(
            request: PromptRequest(
                model: config.model,
                prompt: prompt,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            ))
        spinner.stop()
        printGreen("Successfully returned OpenAI result!!!")
        
        // Save raw response to temporary directory
        print("Ensuring the directory exists")
        try CLIUtility.ensureDirectoryExists(config.temporaryDirectory)
        let fileName = input.title.lowercased().replacingOccurrences(of: " ", with: "_")
        let tempLessonURL = config.temporaryDirectory.appendingPathComponent(
            "\(fileName).md")
        print("tempLessonUrl: \(tempLessonURL.absoluteString)")
        try response.responseString.write(to: tempLessonURL, atomically: true, encoding: .utf8)
        print("Saved lesson to temporary directory: \(tempLessonURL.path)")

        // Validate and parse lesson
        print("Parsing lesson")
        let lesson: Lesson
        do {
            lesson = try parser.parseLesson(from: tempLessonURL)
        } catch {
            throw LessonGenerationError.invalidLesson("Lesson parsing failed: \(error)")
        }
        print("Lesson parsed successfully")

        // Move to final output directory
        print("Moving lesson to output directory")
        let outputURL = config.outputDirectory.appendingPathComponent("\(lesson.metadata.id).md")
        try FileManager.default.moveItem(at: tempLessonURL, to: outputURL)
        printGreen("Lesson generated successfully at \(outputURL.path)!!")

        return outputURL
    }

    // TODO: FUTUUUUURE!

    // /// Generate multiple lessons in batch
    // func generateLessons(inputs: [LessonGenerationInput], progress: ((Double) -> Void)?)
    //     async throws -> [URL]
    // {
    //     var outputURLs: [URL] = []

    //     // Prepare prompts
    //     let promptRequests = try inputs.map { input -> BatchPromptRequest in
    //         guard let promptTemplate = try? String(contentsOf: config.promptFileURL) else {
    //             throw LessonGenerationError.missingPromptFile
    //         }
    //         let prompt = preparePrompt(template: promptTemplate, input: input)
    //         return BatchPromptRequest(
    //             model: config.model,
    //             messages: [["role": "user", "content": prompt]],
    //             temperature: config.temperature,
    //             maxTokens: config.maxTokens
    //         )
    //     }

    //     // Send batch API requests
    //     let response = try await apiService.sendBatchPrompts(
    //         request: BatchPromptRequest(
    //             model: config.model,
    //             messages: promptRequests.flatMap { $0.messages },
    //             temperature: config.temperature,
    //             maxTokens: config.maxTokens
    //         ))

    //     // Process each API response
    //     for (index, responseString) in response.responses.enumerated() {
    //         do {
    //             let input = inputs[index]
    //             let tempLessonURL = config.temporaryDirectory.appendingPathComponent(
    //                 "\(UUID().uuidString).json")
    //             try responseString.write(to: tempLessonURL, atomically: true, encoding: .utf8)

    //             // Validate and parse lesson
    //             let lesson = try parser.parseLesson(from: tempLessonURL)
    //             let outputURL = config.outputDirectory.appendingPathComponent(
    //                 "\(lesson.metadata.id).json")
    //             try FileManager.default.moveItem(at: tempLessonURL, to: outputURL)
    //             outputURLs.append(outputURL)
    //         } catch {
    //             print("Error processing lesson \(index): \(error)")
    //         }

    //         // Update progress
    //         progress?(Double(index + 1) / Double(inputs.count))
    //     }

    //     return outputURLs
    // }
}
