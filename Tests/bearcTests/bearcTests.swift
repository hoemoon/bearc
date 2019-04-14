import XCTest
import class Foundation.Bundle

final class bearcTests: XCTestCase {
	func execute(with arguments: [String]) throws -> String? {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
			return nil
        }

        let fooBinary = productsDirectory.appendingPathComponent("bearc")

        let process = Process()
        process.executableURL = fooBinary
		process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
		return output
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
	
	func testWithArguments() throws {
		let result = try execute(with: ["--outputPath /Users/hoemoon/workspace/bearc/output --tag public"])
		print(result)
	}
}
