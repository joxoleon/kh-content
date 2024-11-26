import Foundation
import KHContentSource

// MARK: - Constants
enum TopicBreakdownConstants {
    static let model = "gpt-4o-mini"
    static let temperature = 0.7
    static let maxTokens = 2000
}

// MARK: - Errors

enum TopicBreakdownError: Error {
    case missingPromptFile
    case invalidTopic(String)
    case apiError(String)
}

// MARK: - Support Types

struct TopicBreakdownInput: Codable, FilePersistable {
    let title: String
    let description: String
    var filename: String {
        return sanitizeString(title)
    }
}

struct BatchTopicBreakdownInput: Codable, FilePersistable {
    let topics: [TopicBreakdownInput]
}

// MARK: - Service

protocol TopicBreakdownServiceProtocol {
    func generateTopicBreakdown(input: TopicBreakdownInput) async throws -> BatchLessonGenerationInput
}

final class TopicBreakdownService: TopicBreakdownServiceProtocol {
    
    // MARK: - Properties
    
    private let apiService: OpenAIAPIProtocol

    // MARK: - Initializers

    init(
        apiService: OpenAIAPIProtocol = OpenAIAPIService(
            apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!)
    ) {
        self.apiService = apiService
    }

    // MARK: - Public Methods

    func generateTopicBreakdowns(inputFilePath: URL, outputDirectory: URL) async throws {
        // Load the input file
        let batchTopicBreakdownInput = try BatchTopicBreakdownInput.load(from: inputFilePath)

        // Generate topic breakdowns for each topic in the input file by calling generateTopicBreakdown in a TaskGroup
        await withTaskGroup(of: Void.self) { group in
            for topic in batchTopicBreakdownInput.topics {
                group.addTask {
                    if let batchLessonGenerationInput = try? await self.generateTopicBreakdown(input: topic) {
                        print("Topic breakdown for \(topic.title) generated successfully")
                        let batchLessonGenerationInputFilePath = outputDirectory.appendingPathComponent("\(topic.filename).json")
                        try? batchLessonGenerationInput.save(to: batchLessonGenerationInputFilePath)
                        print("Topic breakdown for \(topic.title) saved to \(batchLessonGenerationInputFilePath.path)")
                    }
                }
            }
        }

        printGreen("Topic breakdowns generated successfully")
    }

    func generateTopicBreakdown(input: TopicBreakdownInput) async throws -> BatchLessonGenerationInput {
        printGreen("Breaking down topic with title: \(input.title) and focus: \(input.description)")

        // Fetch prompt from prompt factory
        let prompt = try PromptFactory.generatePrompt(for: .topic(title: input.title, focus: input.description))

        // Send request to OpenAI
        printBlue("Sending prompt to OpenAI API")
        let response = try await apiService.sendPrompt( 
            request: PromptRequest(
                model: TopicBreakdownConstants.model,
                prompt: prompt,
                temperature: TopicBreakdownConstants.temperature,
                maxTokens: TopicBreakdownConstants.maxTokens,
                n: 1
            )
        )
        printBlue("Received response from OpenAI API")

        // Process the topic breakdown response (deserialize JSON)
        let batchLessonGenerationIput = try processTopicBreakdownResponse(response, input: input)
        printGreen("Topic broken down successfully!!")

        return batchLessonGenerationIput
    }

    // MARK: - Private Methods

    private func processTopicBreakdownResponse(_ response: SinglePromptResponse, input: TopicBreakdownInput) throws -> BatchLessonGenerationInput {
        guard let data = response.responseString.data(using: .utf8) else {
            throw TopicBreakdownError.apiError("Failed to convert response string to data")
        }
        
        do {
            return try JSONDecoder().decode(BatchLessonGenerationInput.self, from: data)
        } catch {
            throw TopicBreakdownError.apiError("Failed to decode JSON response: \(error.localizedDescription)")
        }
    }
}