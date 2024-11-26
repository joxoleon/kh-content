import Foundation
import KHContentSource

// MARK: - Supporting Models

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

// MARK: - Errors

enum LessonGenerationError: Error {
    case missingPromptFile
    case invalidLesson(String)
    case apiError(String)
}

// MARK: - Service

protocol LessonGenerationServiceProtocol {
    func generateLesson(input: LessonGenerationInput) async throws -> URL
    func generateLessons(batchInput: BatchLessonGenerationInput) async throws -> [URL]
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

    /// Generate multiple lessons in a batch
    func generateLessons(batchInput: BatchLessonGenerationInput) async throws -> [URL] {
        printGreen("Generating \(batchInput.lessons.count) lessons in batch")
        print("Lessons to generate: \(batchInput.lessons.map { $0.title })")
        var outputURLs: [URL] = []

        // Process each lesson input
        for input in batchInput.lessons {
            do {
                printGreen("Generating lesson with title: \(input.title) and focus: \(input.description)")
                // Prepare prompt
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
                let tempLessonURL = config.temporaryDirectory.appendingPathComponent("\(fileName).md")
                print("tempLessonUrl: \(tempLessonURL.absoluteString)")
                try response.responseString.write(to: tempLessonURL, atomically: true, encoding: .utf8)
                print("Saved lesson to temporary directory: \(tempLessonURL.path)")

                // Validate and parse lesson
                print("Parsing lesson")
                let lesson = try parser.parseLesson(from: tempLessonURL)
                print("Lesson parsed successfully")

                // Move to final output directory
                print("Moving lesson to output directory")
                let outputURL = config.outputDirectory.appendingPathComponent("\(lesson.metadata.id).md")
                try FileManager.default.moveItem(at: tempLessonURL, to: outputURL)
                printGreen("Lesson generated successfully at \(outputURL.path)!!")
                outputURLs.append(outputURL)
            } catch {
                print("Error processing lesson \(input.title): \(error)")
            }
        }

        printGreen("Batch generation complete for \(outputURLs.count) lessons")
        print("Lessons generated at: \(outputURLs.map { $0.path })")

        return outputURLs
    }
}
