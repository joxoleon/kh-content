import ArgumentParser
import Foundation

struct TestRun: ParsableCommand {
    func run() throws {
        try KHContentFileUtility.updateLessonGeneratedContentList()
        let list = try KHContentFileUtility.fetchLessonGeneratedContentList()
        print(list)
    }
}