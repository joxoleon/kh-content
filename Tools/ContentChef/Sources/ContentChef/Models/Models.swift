import Foundation

public struct ContentMetadata: Codable {
    let lastUpdatedTimestamp: TimeInterval
}

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

public struct LearningModule: Codable {
    let id: String
    let title: String
    let description: String
    let subModules: [LearningModule]
    let lessons: [String]

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
