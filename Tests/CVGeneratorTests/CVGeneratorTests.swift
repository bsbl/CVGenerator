import XCTest
import class Foundation.Bundle


final class CVGeneratorTests: XCTestCase {
    
    private func runCLI(args: [String]) throws -> String? {
        guard #available(macOS 10.13, *) else {
            return ""
        }
        let fooBinary = productsDirectory.appendingPathComponent("CVGenerator")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
    
    func testNoArgShowUsage() throws {
        let output = try runCLI(args: [])
        XCTAssertTrue(output?.contains("Usage") ?? false, "Usage: expected but got \(String(describing: output))")
    }

    func testMinusMinusHelpShowUsage() throws {
        let output = try runCLI(args: ["--help"])
        XCTAssertTrue(output?.contains("Usage") ?? false, "Usage: expected but got \(String(describing: output))")
    }

    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testNoArgShowUsage", testNoArgShowUsage),
    ]
    
}
