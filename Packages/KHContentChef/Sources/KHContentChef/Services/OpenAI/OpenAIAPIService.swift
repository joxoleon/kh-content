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
    private func sendRequest<T: Codable, U: Codable>(endpoint: String, requestBody: T) async throws -> U {
        guard let url = URL(string: endpoint) else {
            throw OpenAIAPIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
            if let httpBody = urlRequest.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
                print("Request Payload: \(bodyString)")
            }
        } catch {
            throw OpenAIAPIError.invalidRequestEncoding(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status Code: \(httpResponse.statusCode)")
            print("Response Headers: \(httpResponse.allHeaderFields)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIAPIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(U.self, from: data)
        } catch {
            print("Failed to decode response: \(error)")
            throw OpenAIAPIError.invalidResponseDecoding(error)
        }
    }
    
    // MARK: - Single Prompt Request
    func sendPrompt(request: PromptRequest) async throws -> SinglePromptResponse {
        try await sendRequest(endpoint: baseURL, requestBody: request)
    }

    // MARK: - Batch Prompt Request
    func sendBatchPrompts(request: BatchPromptRequest) async throws -> BatchPromptResponse {
        try await sendRequest(endpoint: baseURL, requestBody: request)
    }
}

// MARK: - Models

// Single Prompt Request
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
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
        case n
    }
}

// Batch Prompt Request
struct BatchPromptRequest: Codable {
    let model: String
    let messages: [[String: String]]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
    }
}

// Single Prompt Response
struct SinglePromptResponse: Codable {

    // MARK - Properties

    let responseString: String
    
    // MARK: - Codable

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
    
    // MARK - Properties

    let responses: [String]
    
    // MARK: - Codable

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
