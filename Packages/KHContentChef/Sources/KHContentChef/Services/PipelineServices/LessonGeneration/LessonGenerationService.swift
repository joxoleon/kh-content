import Foundation
import KHContentSource

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
        // Fucking Xcode/Apple is the worst piece of garbage on the planet
        // It can't even handle a simple environment variable
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

        // Prepare prompts
        print("Preparing prompts")
        let promptRequests = try batchInput.lessons.map { input in
            let prompt = try PromptFactory.generatePrompt(for: .lesson(title: input.title, focus: input.description))
            return prompt
        }

        // Send batch API requests
        printGreen("Sending batch requests to OpenAI")
        let spinner = Spinner()
        spinner.start()
        
        let responses = try await apiService.sendBatchPrompts(
            request: BatchPromptRequest(
                model: config.model,
                prompts: promptRequests,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            ))

        spinner.stop()
        printGreen("Successfully returned OpenAI results!!!")

        // Process each API response
        printGreen("Processing responses and verifying lessons")
        for (index, response) in responses.enumerated() {
            do {
                let input = batchInput.lessons[index]
                let fileName = input.title.lowercased().replacingOccurrences(of: " ", with: "_")
                let tempLessonURL = config.temporaryDirectory.appendingPathComponent("\(fileName).md")
                print("tempLessonUrl: \(tempLessonURL.absoluteString)")
                
                try response.responseString.write(to: tempLessonURL, atomically: true, encoding: .utf8)
                print("Saved lesson to temporary directory: \(tempLessonURL.path)")

                // Validate and parse lesson
                print("Validating and parsing lesson: \(input.title)")
                let lesson = try parser.parseLesson(from: tempLessonURL)
                let outputURL = config.outputDirectory.appendingPathComponent("\(lesson.metadata.id).md")
                print("Lesson parsed successfully")
                
                // Move to final output directory
                print("Moving lesson to output directory: \(outputURL.path)")
                try FileManagerUtility.moveItemOverwrite(from: tempLessonURL, to: outputURL)
                print("Lesson generated successfully at \(outputURL.path)!!")

                outputURLs.append(outputURL)
            } catch {
                print("Error processing lesson \(index): \(error)")
            }
        }
        printGreen("Batch generation complete for \(outputURLs.count) lessons")
        print("Lessons generated at: \(outputURLs.map { $0.path })")

        return outputURLs
    }
}
