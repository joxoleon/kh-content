import Foundation

// MARK: - ContentStorageProtocol

protocol ContentStorageProtocol {
    func saveLessons(_ lessons: [Lesson])
    func saveModules(_ modules: [LearningModule])
    func saveMetadata(_ metadata: ContentMetadata)
    
    func loadLessons() -> [Lesson]?
    func loadModules() -> [LearningModule]?
    func loadMetadata() -> ContentMetadata?
}

// MARK: - FileContentStorage

class FileContentStorage: ContentStorageProtocol {
    private let fileManager = FileManager.default
    private let lessonsFileURL: URL
    private let modulesFileURL: URL
    private let metadataFileURL: URL
    
    init() {
        // Setup paths in the documents directory
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        lessonsFileURL = documentsDirectory.appendingPathComponent("lessons.json")
        modulesFileURL = documentsDirectory.appendingPathComponent("modules.json")
        metadataFileURL = documentsDirectory.appendingPathComponent("content_metadata.json")
    }
    
    // MARK: - Save Methods
    
    func saveLessons(_ lessons: [Lesson]) {
        saveData(lessons, to: lessonsFileURL)
    }
    
    func saveModules(_ modules: [LearningModule]) {
        saveData(modules, to: modulesFileURL)
    }
    
    func saveMetadata(_ metadata: ContentMetadata) {
        saveData(metadata, to: metadataFileURL)
    }
    
    // MARK: - Load Methods
    
    func loadLessons() -> [Lesson]? {
        return loadData(from: lessonsFileURL)
    }
    
    func loadModules() -> [LearningModule]? {
        return loadData(from: modulesFileURL)
    }
    
    func loadMetadata() -> ContentMetadata? {
        return loadData(from: metadataFileURL)
    }
    
    // MARK: - Helper Methods
    
    private func saveData<T: Encodable>(_ data: T, to url: URL) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            if #available(macOS 11.0, *) {
                try encodedData.write(to: url, options: [.atomicWrite, .completeFileProtection])
            } else {
                try encodedData.write(to: url, options: [.atomicWrite])
            }
            print("Saved data to \(url.lastPathComponent)")
        } catch {
            print("Failed to save data to \(url.lastPathComponent): \(error)")
        }
    }
    
    private func loadData<T: Decodable>(from url: URL) -> T? {
        do {
            guard fileManager.fileExists(atPath: url.path) else {
                print("No data file found at \(url.lastPathComponent)")
                return nil
            }
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            print("Loaded data from \(url.lastPathComponent)")
            return decodedData
        } catch {
            print("Failed to load data from \(url.lastPathComponent): \(error)")
            return nil
        }
    }
}