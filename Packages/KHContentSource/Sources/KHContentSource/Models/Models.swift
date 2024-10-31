import Foundation

public struct ContentMetadata: Codable {
    public let lastUpdatedTimestamp: TimeInterval

    public init(lastUpdatedTimestamp: TimeInterval) {
        self.lastUpdatedTimestamp = lastUpdatedTimestamp
    }
}

public struct LessonMetadata: Codable {
    public let id: String
    public let title: String
    public let description: String
    public let tags: [String]

    public init(
        title: String,
        description: String,
        tags: [String]
    ) {
        self.id = title.replacingOccurrences(of: " ", with: "_").lowercased()
        self.title = title
        self.description = description
        self.tags = tags
    }
}

public struct Lesson: Codable {
    public let metadata: LessonMetadata
    public let sections: [LessionContentSection]
    public let questions: [Question]

    public init(
        metadata: LessonMetadata,
        sections: [LessionContentSection],
        questions: [Question]
    ) {
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
        case title, description, subModules, lessons
    }

    public init(
        title: String,
        description: String,
        subModules: [LearningModule] = [],
        lessons: [String] = []
    ) {
        self.id = title.replacingOccurrences(of: " ", with: "_").lowercased()
        self.title = title
        self.description = description
        self.subModules = subModules
        self.lessons = lessons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        id = title.replacingOccurrences(of: " ", with: "_").lowercased()
        description = try container.decode(String.self, forKey: .description)
        subModules =
            try container.decodeIfPresent([LearningModule].self, forKey: .subModules) ?? []
        lessons = try container.decodeIfPresent([String].self, forKey: .lessons) ?? []
    }
}
