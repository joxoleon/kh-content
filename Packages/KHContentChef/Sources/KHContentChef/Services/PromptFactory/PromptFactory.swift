import Foundation

enum PromptType {
    case lesson(title: String, focus: String)
}

final class PromptFactory {

    // MARK: - Properties
    private static var prompts: [String: String] = [:]
    private static var isLoaded = false
    private static let templatePath = URL(fileURLWithPath: "../../Content/TemplatePrompts/")

    // MARK: - Public API

    /// Generates a prompt for the given `PromptType`.
    /// - Parameter type: The type of the prompt to generate.
    /// - Returns: The generated prompt string with all placeholders replaced.
    static func generatePrompt(for type: PromptType) throws -> String {
        // Ensure prompts are loaded
        try loadPromptsIfNeeded()

        // Handle the specific prompt type
        switch type {
        case .lesson(let title, let focus):
            guard let template = prompts["lesson"] else {
                throw PromptFactoryError.missingTemplate("lesson")
            }
            return injectParameters(template: template, with: ["title": title, "focus": focus])
        }
    }

    // MARK: - Private Methods

    /// Loads all prompt templates lazily if not already loaded.
    private static func loadPromptsIfNeeded() throws {
        guard !isLoaded else { return }

        // Read files from the template directory
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: templatePath.path) else {
            throw PromptFactoryError.failedToLoadTemplates("Could not read files in directory \(templatePath.path)")
        }

        for file in files {
            let fileURL = templatePath.appendingPathComponent(file)
            guard file.hasSuffix(".md") else { continue } // Only load markdown files
            let templateName = file.replacingOccurrences(of: ".md", with: "").lowercased()

            do {
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                prompts[templateName] = content
            } catch {
                throw PromptFactoryError.failedToLoadTemplates("Failed to load template \(file): \(error)")
            }
        }

        isLoaded = true
    }

    /// Replaces placeholders in the format `{{key}}` within the template string.
    /// - Parameters:
    ///   - template: The template string containing placeholders.
    ///   - values: A dictionary of placeholder keys and their replacement values.
    /// - Returns: The transformed string with placeholders replaced.
    /// - Note: This method is case-sensitive. And make sure that the keys in the `values` dictionary match the placeholders in the template.
    private static func injectParameters(template: String, with values: [String: String]) -> String {
        var result = template
        for (key, value) in values {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return result
    }
}

// MARK: - PromptFactoryError Enum
/// Errors specific to the PromptFactory.
enum PromptFactoryError: Error, CustomStringConvertible {
    case missingTemplate(String)
    case failedToLoadTemplates(String)

    var description: String {
        switch self {
        case .missingTemplate(let templateName):
            return "Template '\(templateName)' is missing or could not be found."
        case .failedToLoadTemplates(let message):
            return "Failed to load templates: \(message)"
        }
    }
}

// MARK: - Example Usage

// #if DEBUG
// do {
//     let lessonPrompt = try PromptFactory.generatePrompt(for: .lesson(
//         title: "MVVM Architecture for iOS Development",
//         focus: "How to use MVVM in combination with SwiftUI."
//     ))
//     print("Generated Lesson Prompt:\n\(lessonPrompt)")

//     let quickSummaryPrompt = try PromptFactory.generatePrompt(for: .quickSummary(
//         topic: "Concurrency in Swift"
//     ))
//     print("Generated Quick Summary Prompt:\n\(quickSummaryPrompt)")

//     let advancedAnalysisPrompt = try PromptFactory.generatePrompt(for: .advancedAnalysis(
//         subject: "Blockchain Scalability",
//         depth: "A technical deep dive into Layer 2 solutions."
//     ))
//     print("Generated Advanced Analysis Prompt:\n\(advancedAnalysisPrompt)")
// } catch {
//     print("Error generating prompt: \(error)")
// }
// #endif
