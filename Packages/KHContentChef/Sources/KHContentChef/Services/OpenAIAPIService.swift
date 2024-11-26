import Foundation

// MARK: - Protocol for the OpenAI API Service
protocol OpenAIAPIProtocol {
    func sendPrompt(request: PromptRequest) async throws -> SinglePromptResponse
    func sendBatchPrompts(request: BatchPromptRequest) async throws -> [SinglePromptResponse]
}

// MARK: - OpenAI API Service
final class OpenAIAPIService: OpenAIAPIProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Unified Request Handler
    private func sendRequest<T: Codable, U: Codable>(requestBody: T) async throws -> U {
        guard let url = URL(string: baseURL) else {
            throw OpenAIAPIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 400 // Increase the timeout interval to 60 seconds
        
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIAPIError.invalidResponse
        }
        
        return try JSONDecoder().decode(U.self, from: data)
    }
    
    // MARK: - Single Prompt Request
    func sendPrompt(request: PromptRequest) async throws -> SinglePromptResponse {
        try await sendRequest(requestBody: request)
    }

    // MARK: - Batch Prompt Requests (Parallel Execution)
    func sendBatchPrompts(request: BatchPromptRequest) async throws -> [SinglePromptResponse] {
        return try await withThrowingTaskGroup(of: (Int, SinglePromptResponse).self) { group in
            // Add tasks to the group with their index
            for (index, prompt) in request.prompts.enumerated() {
                group.addTask {
                    let promptRequest = PromptRequest(
                        model: request.model,
                        prompt: prompt,
                        temperature: request.temperature,
                        maxTokens: request.maxTokens
                    )
                    let response = try await self.sendPrompt(request: promptRequest)
                    return (index, response) // Return the index with the response
                }
            }
            
            var indexedResponses: [(Int, SinglePromptResponse)] = []
            for try await result in group {
                indexedResponses.append(result)
            }
            
            // Sort by the original index and map to just the responses
            return indexedResponses.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }
}

// MARK: - Models

// Single Prompt Request
struct PromptRequest: Codable {
    let model: String
    let messages: [[String: String]]
    let temperature: Double
    let maxTokens: Int
    let n: Int = 1

    init(model: String, prompt: String, temperature: Double, maxTokens: Int, n: Int = 1) {
        self.model = model
        self.messages = [["role": "user", "content": prompt]]
        self.temperature = temperature
        self.maxTokens = maxTokens
    }
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case n
    }
}

// Batch Prompt Request
struct BatchPromptRequest {
    let model: String
    let prompts: [String]
    let temperature: Double
    let maxTokens: Int // When using batch requests, this represents the max tokens per prompt
}

// Single Prompt Response
struct SinglePromptResponse: Codable {
    let responseString: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let choices = try container.decode([Choice].self, forKey: .choices)
        self.responseString = choices.first?.message.content ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode([Choice(message: Choice.Message(content: responseString))], forKey: .choices)
    }
    
    private enum CodingKeys: String, CodingKey {
        case choices
    }
    
    private struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

// MARK: - Errors
enum OpenAIAPIError: Error {
    case invalidURL
    case invalidResponse
}
