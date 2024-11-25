import ArgumentParser
import Foundation

struct GenerateLessons: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Generates lessons from an input file."
    )

    @Argument(help: "The input file path containing lesson data.")
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The output directory for generated lesson files.")
    var outputDir: String

    func run() throws {

    }
}
