import Foundation

// MARK: - ContentStorageProtocol

public protocol ContentStorageProtocol {
    func saveLessons(_ lessons: [Lesson])
    func saveModules(_ modules: [LearningModule])
    func saveMetadata(_ metadata: ContentMetadata)

    func loadLessons() -> [Lesson]?
    func loadModules() -> [LearningModule]?
    func loadMetadata() -> ContentMetadata?
}

// MARK: - FileContentStorage

public class FileContentStorage: ContentStorageProtocol {
    private let fileManager = FileManager.default
    private let lessonsFileURL: URL
    private let modulesFileURL: URL
    private let metadataFileURL: URL

    public init(
        baseDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
    ) {
        lessonsFileURL = baseDirectory.appendingPathComponent("lessons.json")
        modulesFileURL = baseDirectory.appendingPathComponent("modules.json")
        metadataFileURL = baseDirectory.appendingPathComponent("content_metadata.json")
    }

    // MARK: - Save Methods

    public func saveLessons(_ lessons: [Lesson]) {
        saveData(lessons, to: lessonsFileURL)
    }

    public func saveModules(_ modules: [LearningModule]) {
        saveData(modules, to: modulesFileURL)
    }

    public func saveMetadata(_ metadata: ContentMetadata) {
        saveData(metadata, to: metadataFileURL)
    }

    // MARK: - Load Methods

    public func loadLessons() -> [Lesson]? {
        return loadData(from: lessonsFileURL)
    }

    public func loadModules() -> [LearningModule]? {
        return loadData(from: modulesFileURL)
    }

    public func loadMetadata() -> ContentMetadata? {
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
