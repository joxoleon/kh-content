import Foundation

// MARK: - ContentChefNetworking Protocol

protocol ContentRepositoryProtocol {
    func fetchLesson(by id: String) -> Lesson?
    func fetchModule(by id: String) -> LearningModule?
    func updateDataIfNeeded(completion: @escaping (Bool) -> Void)
}

// MARK: - ContentChefNetworking

class ContentRepository: ContentRepositoryProtocol {
    private var lessonsCache: [String: Lesson] = [:]
    private var modulesCache: [String: LearningModule] = [:]
    private let fetcher: ContentFetcherProtocol
    private let storage: ContentStorageProtocol
    
    init(fetcher: ContentFetcherProtocol, storage: ContentStorageProtocol) {
        self.fetcher = fetcher
        self.storage = storage
        loadCachedData()
    }
    
    func fetchLesson(by id: String) -> Lesson? {
        return lessonsCache[id]
    }
    
    func fetchModule(by id: String) -> LearningModule? {
        return modulesCache[id]
    }
    
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
            completion(true)
        }
    }
}

