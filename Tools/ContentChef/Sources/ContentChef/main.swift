import ArgumentParser
import Foundation

struct ContentChef: ParsableCommand {
    @Argument(help: "The root path of the content directory.")
    var contentPath: String

    @Option(name: .shortAndLong, help: "The output path for generated JSON files.")
    var outputPath: String?

    func run() throws {
        print("Running ContentChef...")
        print("Content path:", contentPath)
        print("Output path:", outputPath ?? "No output path provided")
        
        // Here’s where you would call the actual processing logic.
        // For example:
        // let chef = ContentProcessor(contentPath: contentPath, outputPath: outputPath)
        // try chef.processContent()
    }
}

// Instead of `@main`, manually call `ContentChef.main()`
ContentChef.main()
