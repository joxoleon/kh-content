import ArgumentParser
import Foundation
import KHContentSource

struct ContentChef: ParsableCommand {
    @Argument(help: "The root path of the content directory.")
    var contentPath: String

    @Option(name: .shortAndLong, help: "The output path for generated JSON files.")
    var outputPath: String

    func run() throws {

    }


}

// Instead of `@main`, manually call `ContentChef.main()`
ContentChef.main()