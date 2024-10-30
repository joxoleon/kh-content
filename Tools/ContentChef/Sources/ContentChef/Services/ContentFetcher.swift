import Foundation

// MARK: - ContentFetcherProtocol

protocol ContentFetcherProtocol {
    func fetchContentMetadata(completion: @escaping (Result<ContentMetadata, Error>) -> Void)
    func fetchLessons(completion: @escaping (Result<[Lesson], Error>) -> Void)
    func fetchModules(completion: @escaping (Result<[LearningModule], Error>) -> Void)
}

// MARK: - GitHubContentFetcher

class GitHubContentFetcher: ContentFetcherProtocol {
    private let baseURL = "https://raw.githubusercontent.com/jovanradivojsa/kh-content/main/"

    func fetchContentMetadata(completion: @escaping (Result<ContentMetadata, Error>) -> Void) {
        let url = URL(string: "\(baseURL)content_metadata.json")!
        fetchJSON(from: url, completion: completion)
    }
    
    func fetchLessons(completion: @escaping (Result<[Lesson], Error>) -> Void) {
        let url = URL(string: "\(baseURL)lessons.json")!
        fetchJSON(from: url, completion: completion)
    }
    
    func fetchModules(completion: @escaping (Result<[LearningModule], Error>) -> Void) {
        let url = URL(string: "\(baseURL)modules.json")!
        fetchJSON(from: url, completion: completion)
    }
    
    private func fetchJSON<T: Decodable>(from url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
