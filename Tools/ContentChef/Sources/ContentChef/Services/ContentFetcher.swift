import Foundation

// MARK: - ContentFetcherProtocol

protocol ContentFetcherProtocol {
    func fetchContentMetadata(completion: @escaping (Result<ContentMetadata, Error>) -> Void)
    func fetchLessons(completion: @escaping (Result<[Lesson], Error>) -> Void)
    func fetchModules(completion: @escaping (Result<[LearningModule], Error>) -> Void)
}

// MARK: - GitHubContentFetcher

class GitHubContentFetcher: ContentFetcherProtocol {
    private let baseURL = "https://raw.githubusercontent.com/joxoleon/kh-content/main/Content/Output/iOS/"

    func fetchContentMetadata(completion: @escaping (Result<ContentMetadata, Error>) -> Void) {
        let url = URL(string: "\(baseURL)content_metadata.json")!
        fetchJSON(from: url, completion: completion)
    }

    func fetchLessons(completion: @escaping (Result<[Lesson], Error>) -> Void) {
        let url = URL(string: "\(baseURL)all_lessons.json")!
        fetchJSON(from: url, completion: completion)
    }

    func fetchModules(completion: @escaping (Result<[LearningModule], Error>) -> Void) {
        let url = URL(string: "\(baseURL)all_modules.json")!
        fetchJSON(from: url, completion: completion)
    }

    private func fetchJSON<T: Decodable>(
        from url: URL, 
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        print("Fetching JSON from: \(url)")
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
                print("Failed to decode JSON: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw response data: \(jsonString)")  // Print raw response for debugging
                }
                completion(.failure(error))
            }
        }.resume()
    }

}
