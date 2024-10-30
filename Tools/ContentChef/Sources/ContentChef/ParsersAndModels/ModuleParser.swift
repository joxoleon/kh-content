import Foundation
import Yams

// MARK: - Module Data Models

public struct LearningModule: Codable {
    let id: String
    let title: String
    let description: String
    let subModules: [LearningModule]
    let lessons: [String]

    enum CodingKeys: String, CodingKey {
        case title, description, subModules, lessons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        id = title.replacingOccurrences(of: " ", with: "_").lowercased()
        description = try container.decode(String.self, forKey: .description)
        subModules = try container.decodeIfPresent([LearningModule].self, forKey: .subModules) ?? []
        lessons = try container.decodeIfPresent([String].self, forKey: .lessons) ?? []
    }
}

// MARK: - Module Parsing Errors

enum ModuleParsingError: Error {
    case fileNotFound
    case invalidContent
    case yamlDecodingFailed
}

// MARK: - LearningModuleParser Class

class LearningModuleParser {
    
    // MARK: - Parse Single Module
    
    func parseLearningModule(from fileURL: URL) throws -> LearningModule {
        let yamlContent = try String(contentsOf: fileURL)
        
        guard let learningModule = try decodeYAML(yamlContent) else {
            throw ModuleParsingError.invalidContent
        }
        
        return learningModule
    }
    
    // MARK: - Parse All Modules in Directory
    
    func parseModules(in directory: URL) throws -> [LearningModule] {
        print("Parsing module files from input directory \(directory.path)")
        let fileManager = FileManager.default
        let moduleFiles = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            .filter { $0.pathExtension == "yaml" }
        print("Found \(moduleFiles.count) module files")
        print("Module files: \(moduleFiles.map { $0.lastPathComponent })")

        var modules: [LearningModule] = []
        for file in moduleFiles {
            let module = try parseLearningModule(from: file)
            modules.append(module)
        }
        return modules
    }
    
    // MARK: - YAML Decoding
    
    private func decodeYAML(_ yamlContent: String) throws -> LearningModule? {
        let decoder = YAMLDecoder()
        do {
            let learningModule = try decoder.decode(LearningModule.self, from: yamlContent)
            print("Decoded LearningModule:\n\(learningModule)")
            return learningModule
        } catch {
            print("Decoding Error: \(error)")
            throw ModuleParsingError.yamlDecodingFailed
        }
    }
}
