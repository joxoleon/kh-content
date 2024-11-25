import Foundation
import KHContentSource

// MARK: - Supporting Models

struct LessonGenerationInput {
    let title: String
    let description: String
}

struct LessonGenerationConfig {
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
        
        // Prepare prompt - Factory is not injected and I don't give a fuck
        let prompt = try PromptFactory.generatePrompt(for: .lesson(title: input.title, focus: input.description))

        // Send API request
        let response = try await apiService.sendPrompt(
            request: PromptRequest(
                model: config.model,
                prompt: prompt,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            ))

        // Save raw response to temporary directory
        let fileName = input.title.lowercased().replacingOccurrences(of: " ", with: "_")
        let tempLessonURL = config.temporaryDirectory.appendingPathComponent(
            "\(fileName).md")
        try response.responseString.write(to: tempLessonURL, atomically: true, encoding: .utf8)

        // Validate and parse lesson
        let lesson: Lesson
        do {
            lesson = try parser.parseLesson(from: tempLessonURL)
        } catch {
            throw LessonGenerationError.invalidLesson("Lesson parsing failed: \(error)")
        }

        // Move to final output directory
        let outputURL = config.outputDirectory.appendingPathComponent("\(lesson.metadata.id).json")
        try FileManager.default.moveItem(at: tempLessonURL, to: outputURL)

        return outputURL
    }

    // TODO: FUTUUUUURE! (I don't give a fuck)

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
