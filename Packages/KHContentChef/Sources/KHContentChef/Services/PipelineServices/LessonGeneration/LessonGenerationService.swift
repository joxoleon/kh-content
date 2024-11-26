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
        apiService: OpenAIAPIProtocol = OpenAIAPIService(
            apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!),
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

        // Prepare prompt and send request
        let response = try await sendPromptRequest(for: input)

        // Process and save lesson
        let outputURL = try processLessonResponse(response, input: input)
        printGreen("Lesson generated successfully at \(outputURL.path)!!")

        return outputURL
    }

    func generateLessons(batchInput: BatchLessonGenerationInput) async throws -> [URL] {
        printGreen("Lessons to generate: \(batchInput.lessons.map { $0.title })")

        // Filter out already generated lessons
        let filteredBatchInput = batchInput.filterAlreadyGeneratedLessons()

        // Prepare and send batch prompts
        let responses = try await sendBatchPromptRequests(for: filteredBatchInput.lessons)

        // Process each response
        let outputURLs = try await processBatchResponses(responses, lessons: filteredBatchInput.lessons)

        printGreen("Batch generation complete for \(outputURLs.count) lessons")
        print("Lessons generated at: \(outputURLs.map { $0.path })")

        // Update generated content list
        updateGeneratedContentList()

        return outputURLs
    }

    // MARK: - Private Methods

    private func sendPromptRequest(for input: LessonGenerationInput) async throws -> SinglePromptResponse {
        let prompt = try PromptFactory.generatePrompt(
            for: .lesson(title: input.title, focus: input.description)
        )
        printBlue("Sending request to OpenAI")
        let spinner = Spinner()
        spinner.start()
        let response = try await apiService.sendPrompt(
            request: PromptRequest(
                model: config.model,
                prompt: prompt,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            )
        )
        spinner.stop()
        printBlue("Successfully returned OpenAI result!")
        return response
    }

    private func processLessonResponse(_ response: SinglePromptResponse, input: LessonGenerationInput) throws -> URL {
        let tempLessonURL = config.temporaryDirectory.appendingPathComponent("\(input.filename).md")
        let outputURL: URL

        try saveResponseToFile(response.responseString, at: tempLessonURL)
        do {
            let lesson = try parser.parseLesson(from: tempLessonURL)
            outputURL = config.outputDirectory.appendingPathComponent("\(input.filename).md")
            try FileManager.default.moveItem(at: tempLessonURL, to: outputURL)
        } catch {
            throw LessonGenerationError.invalidLesson("Lesson parsing failed: \(error)")
        }

        return outputURL
    }

    private func sendBatchPromptRequests(for lessons: [LessonGenerationInput]) async throws -> [SinglePromptResponse] {
        let promptRequests = try lessons.map { input in
            try PromptFactory.generatePrompt(
                for: .lesson(title: input.title, focus: input.description)
            )
        }
        printBlue("Sending batch requests to OpenAI for \(promptRequests.count) lessons")
        let spinner = Spinner()
        spinner.start()
        let responses = try await apiService.sendBatchPrompts(
            request: BatchPromptRequest(
                model: config.model,
                prompts: promptRequests,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            )
        )
        spinner.stop()
        printBlue("Successfully returned OpenAI results!")
        return responses
    }

    private func processBatchResponses(_ responses: [SinglePromptResponse], lessons: [LessonGenerationInput]) async throws -> [URL] {
        var outputURLs: [URL] = []
        for (index, response) in responses.enumerated() {
            let input = lessons[index]
            do {
                let outputURL = try processLessonResponse(response, input: input)
                outputURLs.append(outputURL)
            } catch {
                print("Error processing lesson \(input.title): \(error)")
            }
        }
        return outputURLs
    }

    private func saveResponseToFile(_ responseString: String, at url: URL) throws {
        print("Saving response to \(url.path)")
        try CLIUtility.ensureDirectoryExists(config.temporaryDirectory)
        try responseString.write(to: url, atomically: true, encoding: .utf8)
    }

    private func updateGeneratedContentList() {
        try? KHContentFileUtility.updateLessonGeneratedContentList()
    }
}
