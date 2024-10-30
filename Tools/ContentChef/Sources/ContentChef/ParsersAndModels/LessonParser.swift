import Foundation

// MARK: - Lesson Data Models

public struct LessonMetadata: Codable {
    let id: String
    let title: String
    let description: String
    let tags: [String]
}

public struct Lesson: Codable {
    let metadata: LessonMetadata
    let sections: [LessionContentSection]
    let questions: [Question]
}

public struct LessionContentSection: Codable {
    let title: String
    let content: String
}

public struct Question: Codable {
    let id: String
    let type: String
    let proficiency: String
    let question: String
    let answers: [String]
    let correctAnswerIndex: Int
    let explanation: String
}

// MARK: - Lesson Parsing Errors

enum LessonParsingError: Error {
    case metadataParsingFailed
    case invalidSection
    case questionsParsingFailed
}

// MARK: - LessonParser Class

class LessonParser {
    
    // MARK: - Delimiters
    
    private let metadataStartDelimiter = "{| metadata |}"
    private let metadataEndDelimiter = "{| endmetadata |}"
    private let questionsStartDelimiter = "{| questions |}"
    private let questionsEndDelimiter = "{| endquestions |}"
    private let sectionRegexPattern = #"=== Section: (.*?) ===\n(.*?)=== EndSection: \1 ==="#
    
    // MARK: - Parse Single Lesson
    
    func parseLesson(from fileURL: URL) throws -> Lesson {
        let content = try String(contentsOf: fileURL)
        let lessonMetadata = try parseMetadata(in: content)
        let sections = parseSections(in: content)
        let questions = try parseQuestions(from: content)
        
        return Lesson(
            metadata: lessonMetadata,
            sections: sections,
            questions: questions
        )
    }
    
    // MARK: - Parse All Lessons in Directory
    
    func parseLessons(in directory: URL) throws -> [Lesson] {
        print("Parsing lesson files from input directory \(directory.path)")
        let fileManager = FileManager.default
        let lessonFiles = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            .filter { $0.pathExtension == "md" }
        print("Found \(lessonFiles.count) lesson files")
        print("Lesson files: \(lessonFiles.map { $0.lastPathComponent })")

        var lessons: [Lesson] = []
        for file in lessonFiles {
            let lesson = try parseLesson(from: file)
            lessons.append(lesson)
        }
        return lessons
    }
    
    // MARK: - Metadata Parsing
    
    private func parseMetadata(in content: String) throws -> LessonMetadata {
        guard let metadataContent = extractContent(from: content, startDelimiter: metadataStartDelimiter, endDelimiter: metadataEndDelimiter) else {
            throw LessonParsingError.metadataParsingFailed
        }
        
        guard let data = metadataContent.data(using: .utf8) else {
            throw LessonParsingError.metadataParsingFailed
        }
        
        return try JSONDecoder().decode(LessonMetadata.self, from: data)
    }
    
    // MARK: - Section Parsing
    
    private func parseSections(in content: String) -> [LessionContentSection] {
        let regex = try? NSRegularExpression(pattern: sectionRegexPattern, options: .dotMatchesLineSeparators)
        let nsContent = content as NSString
        var sections: [LessionContentSection] = []
        
        regex?.enumerateMatches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length)) { match, _, _ in
            if let match = match,
               let titleRange = Range(match.range(at: 1), in: content),
               let contentRange = Range(match.range(at: 2), in: content) {
                
                let title = String(content[titleRange])
                let sectionContent = String(content[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                sections.append(LessionContentSection(title: title, content: sectionContent))
            }
        }
        return sections
    }
    
    // MARK: - Questions Parsing
    
    private func parseQuestions(from content: String) throws -> [Question] {
        guard let questionsData = extractContent(from: content, startDelimiter: questionsStartDelimiter, endDelimiter: questionsEndDelimiter) else {
            throw LessonParsingError.questionsParsingFailed
        }
        
        guard let data = questionsData.data(using: .utf8) else {
            throw LessonParsingError.questionsParsingFailed
        }
        
        return try JSONDecoder().decode([Question].self, from: data)
    }
    
    // MARK: - Helper Methods
    
    private func extractContent(from content: String, startDelimiter: String, endDelimiter: String) -> String? {
        guard let startRange = content.range(of: startDelimiter),
              let endRange = content.range(of: endDelimiter, range: startRange.upperBound..<content.endIndex) else {
            return nil
        }
        
        return String(content[startRange.upperBound..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
