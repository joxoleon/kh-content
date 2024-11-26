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

struct TopicBreakdownOutput: Codable, FilePersistable {
    let title: String
    let description: String
    let batchLessonGenerationInput: BatchLessonGenerationInput
}

// MARK: - Service

final class TopicBreakdownService {
    
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
        do {
            // Load the input file
            let batchTopicBreakdownInput = try BatchTopicBreakdownInput.load(from: inputFilePath)

            // Generate topic breakdowns for each topic in the input file by calling generateTopicBreakdown in a TaskGroup
            await withTaskGroup(of: Void.self) { group in
                for topic in batchTopicBreakdownInput.topics {
                    group.addTask {
                        do {
                            if let topicBreakdownOutput = try? await self.generateTopicBreakdown(input: topic) {
                                print("Topic breakdown for \(topic.title) generated successfully")
                                let batchLessonGenerationInputFilePath = outputDirectory.appendingPathComponent("\(topic.filename).json")
                                try topicBreakdownOutput.save(to: batchLessonGenerationInputFilePath)
                                print("Topic breakdown for \(topic.title) saved to \(batchLessonGenerationInputFilePath.path)")
                            }
                        } catch {
                            print("Failed to generate topic breakdown for \(topic.title): \(error)")
                        }
                    }
                }
            }

            printGreen("Topic breakdowns generated successfully")
        } catch {
            print("Failed to load input file: \(error)")
            throw TopicBreakdownError.missingPromptFile
        }
    }

    func generateTopicBreakdown(input: TopicBreakdownInput) async throws -> TopicBreakdownOutput {
        printGreen("Breaking down topic with title: \(input.title) and focus: \(input.description)")

        do {
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
            let topicBreakdownOutput = try processTopicBreakdownResponse(response, input: input)
            printGreen("Topic broken down successfully!!")

            return topicBreakdownOutput
        } catch {
            print("Failed to generate topic breakdown: \(error)")
            throw TopicBreakdownError.apiError(error.localizedDescription)
        }
    }

    // MARK: - Private Methods

    private func processTopicBreakdownResponse(_ response: SinglePromptResponse, input: TopicBreakdownInput) throws -> TopicBreakdownOutput {
        // Remove Markdown code block delimiters
        let cleanedResponseString = response.responseString
            .replacingOccurrences(of: "```json\n", with: "")
            .replacingOccurrences(of: "\n```", with: "")
        
        guard let data = cleanedResponseString.data(using: .utf8) else {
            throw TopicBreakdownError.apiError("Failed to convert response string to data")
        }
        
        do {
            let batchLessonGenerationInput = try JSONDecoder().decode(BatchLessonGenerationInput.self, from: data)
            return TopicBreakdownOutput(
                title: input.title,
                description: input.description,
                batchLessonGenerationInput: batchLessonGenerationInput
            )
        } catch {
            throw TopicBreakdownError.apiError("Failed to decode JSON response: \(error.localizedDescription)")
        }
    }
}