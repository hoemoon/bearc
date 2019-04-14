import Foundation

// TODO: 진행상황 보여주기
// TODO: 에러 보여주기
// TODO: 메뉴얼 보여주기

struct InputHandler {
	enum CommandKey: String {
		case outputPath
		case tag
	}
	
	enum BearCommanlineError: Error {
		case invalidInput
	}
	
	private func showManual() {
		print("manual")
	}
	
	private func handleInvalidInput() {
		print("invalid input")
		print("Type `bearc help` for manual.")
	}
	
	private func convert(_ input: String) throws -> [String: String] {
		var result = [String: String]()
		let components = input.components(separatedBy: " ")
			.filter { $0.count != 0 }

		for index in stride(from: 0, to: components.endIndex, by: 2) {
			let key = components[index]
				.replacingOccurrences(of: "--", with: "")
			let value = components[index + 1]
			guard CommandKey(rawValue: key) != nil else { throw BearCommanlineError.invalidInput }
			result[key] = value
		}
		return result
	}
	
	func main(_ arguments: [String]) {
		guard arguments.count > 1 else {
			handleInvalidInput()
			return
		}
		let userInput = arguments[1]
			.trimmingCharacters(in: .whitespacesAndNewlines)
		
		do {
			let dict = try convert(userInput)
			guard let tag = dict[CommandKey.tag.rawValue] else { throw BearCommanlineError.invalidInput }
			guard let outputPath = dict[CommandKey.outputPath.rawValue] else { throw BearCommanlineError.invalidInput }
			try Extractor().execute(
				with: [tag],
				into: URL(fileURLWithPath: outputPath)
			)
		} catch {
			print(error)
			return
		}
	}
}

let extractor = InputHandler()
extractor.main(CommandLine.arguments)
