import Foundation

public struct ContentMetadata: Codable {
    public let lastUpdatedTimestamp: TimeInterval

    public init(lastUpdatedTimestamp: TimeInterval) {
        self.lastUpdatedTimestamp = lastUpdatedTimestamp
    }
}

public struct LessonMetadata: Codable {
    public let title: String
    public let description: String
    public let tags: [String]

    public init(
        title: String,
        description: String,
        tags: [String]
    ) {
        self.title = title
        self.description = description
        self.tags = tags
    }
}

public struct Lesson: Codable {
    public let id: String
    public var metadata: LessonMetadata
    public let sections: [LessionContentSection]
    public let questions: [Question]

    public init(
        id: String,
        metadata: LessonMetadata,
        sections: [LessionContentSection],
        questions: [Question]
    ) {
        self.id = id
        self.metadata = metadata
        self.sections = sections
        self.questions = questions
    }
}

public struct LessionContentSection: Codable {
    public let title: String
    public let content: String

    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}

public struct Question: Codable {
    public let id: String
    public let type: String
    public let proficiency: String
    public let question: String
    public let answers: [String]
    public let correctAnswerIndex: Int
    public let explanation: String

    public init(
        id: String,
        type: String,
        proficiency: String,
        question: String,
        answers: [String],
        correctAnswerIndex: Int,
        explanation: String
    ) {
        self.id = id
        self.type = type
        self.proficiency = proficiency
        self.question = question
        self.answers = answers
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
    }
}

public struct LearningModule: Codable {
    public let id: String
    public let title: String
    public let description: String
    public let subModules: [LearningModule]
    public let lessons: [String]

    enum CodingKeys: String, CodingKey {
        case title, description, subModules, lessons, id
    }

    public init(
        id: String,
        title: String,
        description: String,
        subModules: [LearningModule] = [],
        lessons: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.subModules = subModules
        self.lessons = lessons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        subModules =
            try container.decodeIfPresent([LearningModule].self, forKey: .subModules) ?? []
        lessons = try container.decodeIfPresent([String].self, forKey: .lessons) ?? []
    }
}


// MARK: - Utility functions

public func sanitizeString(_ string: String) -> String {
    let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|.,':;{}[]()!@#$%^&*+-=")
    let sanitizedString = string
        .components(separatedBy: invalidCharacters)
        .joined()
    return sanitizedString.replacingOccurrences(of: " ", with: "_").lowercased()
}
