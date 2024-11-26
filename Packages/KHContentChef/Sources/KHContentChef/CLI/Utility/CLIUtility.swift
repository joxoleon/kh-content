import Foundation

enum CLIUtility {
    static func ensureDirectoryExists(_ directory: URL) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    static func saveJSON<T: Encodable>(_ object: T, to url: URL) throws {
        let jsonData = try JSONEncoder().encode(object)
        let prettyJsonData = try serializeToPrettyJSON(jsonData)
        try writeJSONData(prettyJsonData, to: url)
    }

    static func serializeToPrettyJSON(_ data: Data) throws -> Data {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
    }

    static func writeJSONData(_ data: Data, to url: URL) throws {
        try data.write(to: url)
    }
}

func printGreen(_ message: String) {
    print("\u{001B}[0;32m\(message)\u{001B}[0;0m")
}

func printRed(_ message: String) {
    print("\u{001B}[0;31m\(message)\u{001B}[0;0m")
}

func printYellow(_ message: String) {
    print("\u{001B}[0;33m\(message)\u{001B}[0;0m")
}


class Spinner {
    private var isSpinning = false
    private let spinnerFrames = ["|", "/", "-", "\\"]
    private var currentFrame = 0
    private let greenColor = "\u{001B}[0;32m"
    private let resetColor = "\u{001B}[0m"

    func start() {
        isSpinning = true
        DispatchQueue.global().async {
            while self.isSpinning {
                print("\r\(self.greenColor)\(self.spinnerFrames[self.currentFrame])\(self.resetColor)", terminator: "")
                fflush(stdout)
                self.currentFrame = (self.currentFrame + 1) % self.spinnerFrames.count
                usleep(100000) // 100ms
            }
        }
    }

    func stop() {
        isSpinning = false
        print("\r ", terminator: "") // Clear the spinner
    }
}