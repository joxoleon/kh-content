// import Foundation
// import KHContentSource

// // MARK: - Supporting Models

// struct LessonGenerationInput {
//     let title: String
//     let description: String
// }

// struct LessonGenerationConfig {
//     let promptFileURL: URL
//     let temporaryDirectory: URL
//     let outputDirectory: URL
//     let model: String
//     let temperature: Double
//     let maxTokens: Int

//     init(promptFileURL: URL = URL(fileURLWithPath: "./Resources/Prompts/lesson_query.txt"),
//          temporaryDirectory: URL = FileManager.default.temporaryDirectory,
//          outputDirectory: URL = URL(fileURLWithPath: "./GeneratedLessons"),
//          model: String = "gpt-4",
//          temperature: Double = 0.7,
//          maxTokens: Int = 1500) {
//         self.promptFileURL = promptFileURL
//         self.temporaryDirectory = temporaryDirectory
//         self.outputDirectory = outputDirectory
//         self.model = model
//         self.temperature = temperature
//         self.maxTokens = maxTokens
//     }
// }

// // MARK: - Errors

// enum LessonGenerationError: Error {
//     case missingPromptFile
//     case invalidLesson(String)
//     case apiError(String)
// }

// // MARK: - Service

// protocol LessonGenerationServiceProtocol {
//     func generateLesson(input: LessonGenerationInput) async throws -> URL
//     func generateLessons(inputs: [LessonGenerationInput], progress: ((Double) -> Void)?) async throws -> [URL]
// }

// final class LessonGenerationService: LessonGenerationServiceProtocol {

//     // MARK: - Properties

//     private let apiService: OpenAIAPIProtocol
//     private let parser: LessonParser
//     private let config: LessonGenerationConfig

//     // Singleton instance
//     static let shared = LessonGenerationService()

//     private init(apiService: OpenAIAPIProtocol = OpenAIAPIService(apiKey: "your-openai-api-key"),
//                  parser: LessonParser = LessonParser(),
//                  config: LessonGenerationConfig = LessonGenerationConfig()) {
//         self.apiService = apiService
//         self.parser = parser
//         self.config = config
//     }

//     // MARK: - Public Methods

//     /// Generate a single lesson
//     func generateLesson(input: LessonGenerationInput) async throws -> URL {
//         // Load prompt template
//         guard let promptTemplate = try? String(contentsOf: config.promptFileURL) else {
//             throw LessonGenerationError.missingPromptFile
//         }

//         // Prepare prompt with placeholders
//         let prompt = preparePrompt(template: promptTemplate, input: input)

//         // Send API request
//         let response = try await apiService.sendPrompt(request: PromptRequest(
//             model: config.model,
//             prompt: prompt,
//             temperature: config.temperature,
//             maxTokens: config.maxTokens
//         ))

//         // Save raw response to temporary directory
//         let tempLessonURL = config.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
//         try response.responseString.write(to: tempLessonURL, atomically: true, encoding: .utf8)

//         // Validate and parse lesson
//         let lesson: Lesson
//         do {
//             lesson = try parser.parseLesson(from: tempLessonURL)
//         } catch {
//             throw LessonGenerationError.invalidLesson("Lesson parsing failed: \(error)")
//         }

//         // Move to final output directory
//         let outputURL = config.outputDirectory.appendingPathComponent("\(lesson.metadata.id).json")
//         try FileManager.default.moveItem(at: tempLessonURL, to: outputURL)

//         return outputURL
//     }

//     /// Generate multiple lessons in batch
//     func generateLessons(inputs: [LessonGenerationInput], progress: ((Double) -> Void)?) async throws -> [URL] {
//         var outputURLs: [URL] = []

//         // Prepare prompts
//         let promptRequests = try inputs.map { input -> PromptRequest in
//             guard let promptTemplate = try? String(contentsOf: config.promptFileURL) else {
//                 throw LessonGenerationError.missingPromptFile
//             }
//             let prompt = preparePrompt(template: promptTemplate, input: input)
//             return PromptRequest(
//                 model: config.model,
//                 prompt: prompt,
//                 temperature: config.temperature,
//                 maxTokens: config.maxTokens,
//                 n: 1
//             )
//         }

//         // Send batch API requests
//         let responses = try await apiService.sendBatchPrompts(request: promptRequests)

//         // Process each API response
//         for (index, response) in responses.enumerated() {
//             do {
//                 let input = inputs[index]
//                 let tempLessonURL = config.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
//                 try response.responseString.write(to: tempLessonURL, atomically: true, encoding: .utf8)

//                 // Validate and parse lesson
//                 let lesson = try parser.parseLesson(from: tempLessonURL)
//                 let outputURL = config.outputDirectory.appendingPathComponent("\(lesson.metadata.id).json")
//                 try FileManager.default.moveItem(at: tempLessonURL, to: outputURL)
//                 outputURLs.append(outputURL)
//             } catch {
//                 print("Error processing lesson \(index): \(error)")
//             }

//             // Update progress
//             progress?(Double(index + 1) / Double(inputs.count))
//         }

//         return outputURLs
//     }

//     // MARK: - Private Helper Methods

//     private func preparePrompt(template: String, input: LessonGenerationInput) -> String {
//         return template
//             .replacingOccurrences(of: "{{title}}", with: input.title)
//             .replacingOccurrences(of: "{{description}}", with: input.description)
//     }
// }
