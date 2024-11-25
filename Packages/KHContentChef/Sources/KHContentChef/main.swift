import ArgumentParser
import Foundation

struct ContentChef: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "ContentChef is a CLI tool for processing and publishing content.",
        subcommands: [
            PublishContent.self,
            GenerateLessons.self // Add other commands here
        ]
        // defaultSubcommand: PublishContent.self
    )
}

// Manually call `ContentChef.main()` to avoid the `@main` attribute.
ContentChef.main()

