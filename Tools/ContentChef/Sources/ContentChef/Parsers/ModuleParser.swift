import Foundation
import Yams

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
        let fileManager = FileManager.default
        let moduleFiles = try fileManager.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles
        )
        .filter { $0.pathExtension == "yaml" }

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
            return learningModule
        } catch {
            print("Decoding Error: \(error)")
            throw ModuleParsingError.yamlDecodingFailed
        }
    }
}
