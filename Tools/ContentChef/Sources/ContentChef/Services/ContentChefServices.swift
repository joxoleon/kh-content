import Foundation

// MARK: - ContentChefNetworking Protocol

protocol ContentChefNetworkingProtocol {
    func fetchLesson(by id: String) -> Lesson?
    func fetchModule(by id: String) -> LearningModule?
    func updateDataIfNeeded(completion: @escaping (Bool) -> Void)
}

// MARK: - ContentFetcherProtocol

protocol ContentFetcherProtocol {
    func fetchContentMetadata(completion: @escaping (Result<ContentMetadata, Error>) -> Void)
    func fetchLessons(completion: @escaping (Result<[Lesson], Error>) -> Void)
    func fetchModules(completion: @escaping (Result<[LearningModule], Error>) -> Void)
}

// MARK: - ContentStorageProtocol

protocol ContentStorageProtocol {
    func saveLessons(_ lessons: [Lesson])
    func saveModules(_ modules: [LearningModule])
    func saveMetadata(_ metadata: ContentMetadata)
    
    func loadLessons() -> [Lesson]?
    func loadModules() -> [LearningModule]?
    func loadMetadata() -> ContentMetadata?
}

// MARK: - ContentChefNetworking

class ContentChefNetworking: ContentChefNetworkingProtocol {
    private var lessonsCache: [String: Lesson] = [:]
    private var modulesCache: [String: LearningModule] = [:]
    private let fetcher: ContentFetcherProtocol
    private let storage: ContentStorageProtocol
    
    init(fetcher: ContentFetcherProtocol, storage: ContentStorageProtocol) {
        self.fetcher = fetcher
        self.storage = storage
        loadCachedData()
    }
    
    // Fetch lesson by id
    func fetchLesson(by id: String) -> Lesson? {
        return lessonsCache[id]
    }
    
    // Fetch module by id
    func fetchModule(by id: String) -> LearningModule? {
        return modulesCache[id]
    }
    
    // Load cached data from storage
    private func loadCachedData() {
        if let lessons = storage.loadLessons() {
            for lesson in lessons {
                lessonsCache[lesson.metadata.id] = lesson
            }
        }
        if let modules = storage.loadModules() {
            for module in modules {
                modulesCache[module.id] = module
            }
        }
    }
    
    // Update data if needed based on metadata timestamp
    func updateDataIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let localMetadata = storage.loadMetadata() else {
            fetchAndUpdateData(completion: completion)
            return
        }
        
        fetcher.fetchContentMetadata { [weak self] result in
            switch result {
            case .success(let remoteMetadata):
                if remoteMetadata.lastUpdatedTimestamp > localMetadata.lastUpdatedTimestamp {
                    self?.fetchAndUpdateData(completion: completion)
                } else {
                    completion(false) // Data is current
                }
            case .failure:
                completion(false) // Handle error (optional: keep local data as fallback)
            }
        }
    }
    
    // Fetch and update data, storing results in caches and local storage
    private func fetchAndUpdateData(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        fetcher.fetchLessons { [weak self] result in
            if case .success(let lessons) = result {
                self?.storage.saveLessons(lessons)
                for lesson in lessons {
                    self?.lessonsCache[lesson.metadata.id] = lesson
                }
            }
            group.leave()
        }
        
        group.enter()
        fetcher.fetchModules { [weak self] result in
            if case .success(let modules) = result {
                self?.storage.saveModules(modules)
                for module in modules {
                    self?.modulesCache[module.id] = module
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(true) // All data updated
        }
    }
}

// MARK: - GitHubContentFetcher

class GitHubContentFetcher: ContentFetcherProtocol {
    private let baseURL = "https://raw.githubusercontent.com/YOUR_GITHUB_USER/YOUR_REPO_NAME/main/"

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

// MARK: - UserDefaultsContentStorage

class UserDefaultsContentStorage: ContentStorageProtocol {
    private let lessonsKey = "content_lessons"
    private let modulesKey = "content_modules"
    private let metadataKey = "content_metadata"
    private let userDefaults = UserDefaults.standard
    
    func saveLessons(_ lessons: [Lesson]) {
        if let data = try? JSONEncoder().encode(lessons) {
            userDefaults.set(data, forKey: lessonsKey)
        }
    }
    
    func saveModules(_ modules: [LearningModule]) {
        if let data = try? JSONEncoder().encode(modules) {
            userDefaults.set(data, forKey: modulesKey)
        }
    }
    
    func saveMetadata(_ metadata: ContentMetadata) {
        if let data = try? JSONEncoder().encode(metadata) {
            userDefaults.set(data, forKey: metadataKey)
        }
    }
    
    func loadLessons() -> [Lesson]? {
        guard let data = userDefaults.data(forKey: lessonsKey),
              let lessons = try? JSONDecoder().decode([Lesson].self, from: data) else {
            return nil
        }
        return lessons
    }
    
    func loadModules() -> [LearningModule]? {
        guard let data = userDefaults.data(forKey: modulesKey),
              let modules = try? JSONDecoder().decode([LearningModule].self, from: data) else {
            return nil
        }
        return modules
    }
    
    func loadMetadata() -> ContentMetadata? {
        guard let data = userDefaults.data(forKey: metadataKey),
              let metadata = try? JSONDecoder().decode(ContentMetadata.self, from: data) else {
            return nil
        }
        return metadata
    }
}
