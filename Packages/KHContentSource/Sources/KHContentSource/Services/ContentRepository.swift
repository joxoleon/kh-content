import Foundation

public enum ContentRepositoryError: Error {
    case metadataFetchFailed
    case contentFetchFailed
}

public protocol ContentRepositoryProtocol {
    func fetchLessonIdCatalog() -> [String]
    func fetchLesson(by id: String) -> Lesson?
    func fetchLessons(by ids: [String]) -> [Lesson]
    
    func fetchModuleIdCatalog() -> [String]
    func fetchModule(by id: String) -> LearningModule?
    func fetchModules(by ids: [String]) -> [LearningModule]
    
    func updateDataIfNeeded() async throws -> Bool
}

public class ContentRepository: ContentRepositoryProtocol {
    private var lessonsCache: [String: Lesson] = [:]
    private var modulesCache: [String: LearningModule] = [:]
    private let fetcher: ContentFetcherProtocol
    private let storage: ContentStorageProtocol
    
    public init(fetcher: ContentFetcherProtocol, storage: ContentStorageProtocol) {
        self.fetcher = fetcher
        self.storage = storage
        loadCachedData()
    }

    public func fetchLessonIdCatalog() -> [String] {
        return Array(lessonsCache.keys)
    }

    public func fetchLesson(by id: String) -> Lesson? {
        return lessonsCache[id]
    }

    public func fetchLessons(by ids: [String]) -> [Lesson] {
        return ids.compactMap { lessonsCache[$0] }
    }

    public func fetchModuleIdCatalog() -> [String] {
        return Array(modulesCache.keys)
    }

    public func fetchModule(by id: String) -> LearningModule? {
        return modulesCache[id]
    }

    public func fetchModules(by ids: [String]) -> [LearningModule] {
        return ids.compactMap { modulesCache[$0] }
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
    
    public func updateDataIfNeeded() async throws -> Bool {
        guard let localMetadata = storage.loadMetadata() else {
            return try await fetchAndUpdateData()
        }
        
        do {
            let remoteMetadata = try await fetcher.fetchContentMetadata()
            if remoteMetadata.lastUpdatedTimestamp > localMetadata.lastUpdatedTimestamp + 0.1 { // Add a small buffer for floating point comparison
                return try await fetchAndUpdateData()
            } else {
                return false
            }
        } catch {
            throw ContentRepositoryError.metadataFetchFailed
        }
    }
    
    private func fetchAndUpdateData() async throws -> Bool {
        async let lessonsResult = fetcher.fetchLessons()
        async let modulesResult = fetcher.fetchModules()
        
        do {
            let lessons = try await lessonsResult
            storage.saveLessons(lessons)
            for lesson in lessons {
                lessonsCache[lesson.metadata.id] = lesson
            }
            
            let modules = try await modulesResult
            storage.saveModules(modules)
            for module in modules {
                modulesCache[module.id] = module
            }
            
            return true
        } catch {
            print("Error fetching content: \(error)")
            throw ContentRepositoryError.contentFetchFailed
        }
    }
}

