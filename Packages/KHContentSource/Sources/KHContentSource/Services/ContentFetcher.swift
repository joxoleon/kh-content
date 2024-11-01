import Foundation

// MARK: - ContentFetcherProtocol

public protocol ContentFetcherProtocol {
    func fetchContentMetadata() async throws -> ContentMetadata
    func fetchLessons() async throws -> [Lesson]
    func fetchModules() async throws -> [LearningModule]
}

// MARK: - GitHubContentFetcher

public class GitHubContentFetcher: ContentFetcherProtocol {
    
    // MARK: - Properties

    private var baseURL = "https://raw.githubusercontent.com/joxoleon/kh-content/main/Content/Output/iOS/"

    // MARK: - Initialization

    public init(baseUrl: String? = nil) {
        if let baseUrl = baseUrl {
            self.baseURL = baseUrl
        }
    }

    // MARK: - Methods

    public func fetchContentMetadata() async throws -> ContentMetadata {
        let url = URL(string: "\(baseURL)content_metadata.json")!
        return try await fetchJSON(from: url)
    }

    public func fetchLessons() async throws -> [Lesson] {
        let url = URL(string: "\(baseURL)all_lessons.json")!
        return try await fetchJSON(from: url)
    }

    public func fetchModules() async throws -> [LearningModule] {
        let url = URL(string: "\(baseURL)all_modules.json")!
        return try await fetchJSON(from: url)
    }

    private func fetchJSON<T: Decodable>(from url: URL) async throws -> T {
        print("Fetching JSON from: \(url)")
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("Failed to decode JSON: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(jsonString)")  // Print raw response for debugging
            }
            throw error
        }
    }

}
