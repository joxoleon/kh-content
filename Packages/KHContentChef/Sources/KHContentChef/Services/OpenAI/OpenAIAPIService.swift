import Foundation

// MARK: - Protocol for the OpenAI API Service
protocol OpenAIAPIProtocol {
    func sendPrompt(request: PromptRequest) async throws -> SinglePromptResponse
    func sendBatchPrompts(request: BatchPromptRequest) async throws -> BatchPromptResponse
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
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw OpenAIAPIError.invalidRequestEncoding(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIAPIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(U.self, from: data)
        } catch {
            throw OpenAIAPIError.invalidResponseDecoding(error)
        }
    }
    
    // MARK: - Single Prompt Request
    func sendPrompt(request: PromptRequest) async throws -> SinglePromptResponse {
        try await sendRequest(requestBody: request)
    }

    // MARK: - Batch Prompt Request
    func sendBatchPrompts(request: BatchPromptRequest) async throws -> BatchPromptResponse {
        try await sendRequest(requestBody: request)
    }
}

// MARK: - Models

struct PromptRequest: Codable {
    let model: String
    let messages: [[String: String]]
    let temperature: Double
    let maxTokens: Int
    let n: Int

    init(model: String, prompt: String, temperature: Double, maxTokens: Int) {
        self.model = model
        self.messages = [["role": "user", "content": prompt]]
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.n = 1
    }
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case n
    }
}

struct BatchPromptRequest: Codable {
    let model: String
    let messages: [[String: String]]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

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

// Batch Prompt Response
struct BatchPromptResponse: Codable {
    let responses: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let choices = try container.decode([Choice].self, forKey: .choices)
        self.responses = choices.compactMap { $0.message.content }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(responses.map { Choice(message: Choice.Message(content: $0)) }, forKey: .choices)
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
    case invalidRequestEncoding(Error)
    case invalidResponseDecoding(Error)
}
