import Foundation

enum CLIUtility {
    static func ensureDirectoryExists(_ directory: URL) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    static func saveJSON<T: Encodable>(_ object: T, to url: URL) throws {
        let jsonData = try JSONEncoder().encode(object)
        let prettyJsonData = try serializeToPrettyJSON(jsonData)
        try writeJSONData(prettyJsonData, to: url)
    }

    static func serializeToPrettyJSON(_ data: Data) throws -> Data {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
    }

    static func writeJSONData(_ data: Data, to url: URL) throws {
        try data.write(to: url)
    }
}