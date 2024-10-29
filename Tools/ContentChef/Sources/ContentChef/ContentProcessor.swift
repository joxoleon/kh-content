// import Foundation
// import Yams

// class ContentProcessor {
//     let contentPath: String
//     let outputPath: String
    
//     init(contentPath: String, outputPath: String) {
//         self.contentPath = contentPath
//         self.outputPath = outputPath
//     }
    
//     func processContent() throws {
//         let lessons = try parseLessons()
//         let modules = try parseModules()
        
//         try writeJSON(data: lessons, toFile: "lessons.json")
//         try writeJSON(data: modules, toFile: "modules.json")
//     }
    
//     private func parseLessons() throws -> [Lesson] {
//         // Implement logic to scan for Markdown files in Lessons directory and parse each one
//     }
    
//     private func parseModules() throws -> [Module] {
//         // Implement logic to scan for YAML files in Modules directory and parse each one
//     }
    
//     private func writeJSON<T: Encodable>(data: T, toFile fileName: String) throws {
//         let encoder = JSONEncoder()
//         encoder.outputFormatting = .prettyPrinted
        
//         let jsonData = try encoder.encode(data)
//         let fileURL = URL(fileURLWithPath: outputPath).appendingPathComponent(fileName)
        
//         try jsonData.write(to: fileURL)
//         print("JSON written to \(fileURL.path)")
//     }
// }
