import ArgumentParser
import Foundation

struct ContentChef: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "ContentChef is a CLI tool for processing and publishing content.",
        subcommands: [
            TestRun.self,
            PublishContent.self,
            BreakdownTopics.self,
            GenerateLesson.self,
            GenerateLessonsFromTopics.self,
            GenerateLessons.self,
            BuildTopLevelModule.self
        ],
        defaultSubcommand: TestRun.self
    )
}

// Manually call `ContentChef.main()` to avoid the `@main` attribute.
ContentChef.main()

