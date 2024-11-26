import ArgumentParser
import Foundation

struct TestRun: ParsableCommand {
    func run() throws {
        let list = try KHContentFileUtility.fetchLessonGeneratedContentList()
        print(list)
    }
}