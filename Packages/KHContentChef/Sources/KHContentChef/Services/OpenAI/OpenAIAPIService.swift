import Foundation

// MARK: - Protocol for the OpenAI API Service
protocol OpenAIAPIProtocol {
    func sendPrompt(request: PromptRequest, completion: @escaping (Result<PromptResponse, Error>) -> Void)
    func sendBatchPrompts(requests: [PromptRequest], completion: @escaping (Result<[PromptResponse], Error>) -> Void)
}

// MARK: - OpenAI API Service
final class OpenAIAPIService: OpenAIAPIProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions" // Update as necessary
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendPrompt(request: PromptRequest, completion: @escaping (Result<PromptResponse, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(OpenAIAPIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(OpenAIAPIError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(OpenAIAPIError.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(PromptResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func sendBatchPrompts(requests: [PromptRequest], completion: @escaping (Result<[PromptResponse], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(OpenAIAPIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare batch request payload
        let messages = requests.map { ["role": "user", "content": $0.prompt] }
        let batchPayload: [String: Any] = [
            "model": requests.first?.model ?? "gpt-4",
            "messages": messages,
            "temperature": requests.first?.temperature ?? 0.7,
            "max_tokens": requests.first?.maxTokens ?? 100,
            "n": 1 // Always 1 choice per prompt in batch mode
        ]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: batchPayload, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(OpenAIAPIError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(OpenAIAPIError.noData))
                return
            }
            
            do {
                let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let choices = responseDict?["choices"] as? [[String: Any]]
                let responses = choices?.compactMap { choice -> PromptResponse? in
                    guard let content = (choice["message"] as? [String: Any])?["content"] as? String else { return nil }
                    return PromptResponse(responseString: content)
                } ?? []
                completion(.success(responses))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

// MARK: - Models
struct PromptRequest: Codable {

    // MARK: - Properties

    let model: String
    let prompt: String
    let temperature: Double
    let maxTokens: Int
    let n: Int // Number of choices to generate (default: 1)
    
    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case model
        case prompt = "messages"
        case temperature
        case maxTokens = "max_tokens"
        case n
    }
    
    init(model: String, prompt: String, temperature: Double, maxTokens: Int, n: Int = 1) {
        self.model = model
        self.prompt = prompt
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.n = n
    }
}

struct PromptResponse: Codable {
    
    // MARK: - Properties

    let responseString: String

    // MARK: - Initialization

    init(responseString: String) {
        self.responseString = responseString
    }

    // MARK: - Codable

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let choices = [Choice(message: Choice.Message(content: responseString))]
        try container.encode(choices, forKey: .choices)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let choices = try container.decode([Choice].self, forKey: .choices)
        self.responseString = choices.first?.message.content ?? ""
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
    case noData
}

// // MARK: - Example Usage
// #if DEBUG
// let apiService = OpenAIAPIService(apiKey: "your-openai-api-key")

// // Single Prompt Example
// let singleRequest = PromptRequest(model: "gpt-4", prompt: "What is the capital of France?", temperature: 0.7, maxTokens: 100)
// apiService.sendPrompt(request: singleRequest) { result in
//     switch result {
//     case .success(let response):
//         print("Single Response: \(response.responseString)")
//     case .failure(let error):
//         print("Error: \(error)")
//     }
// }

// // Batch Prompt Example
// let batchRequests = [
//     PromptRequest(model: "gpt-4", prompt: "Define artificial intelligence.", temperature: 0.7, maxTokens: 100),
//     PromptRequest(model: "gpt-4", prompt: "Explain the theory of relativity.", temperature: 0.7, maxTokens: 100)
// ]

// apiService.sendBatchPrompts(requests: batchRequests) { result in
//     switch result {
//     case .success(let responses):
//         for (index, response) in responses.enumerated() {
//             print("Batch Response \(index + 1): \(response.responseString)")
//         }
//     case .failure(let error):
//         print("Batch Error: \(error)")
//     }
// }
// #endif
