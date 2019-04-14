import Foundation

// TODO: 진행상황 보여주기
// TODO: 에러 보여주기
// TODO: 메뉴얼 보여주기

struct InputHandler {
	enum CommandKey: String {
		case outputPath
		case tags
		
		init?(rawValue: String) {
			switch rawValue {
			case "outputPath", "o":
				self = .outputPath
			case "tags", "t":
				self = .tags
			default:
				return nil
			}
		}
	}
	
	enum BearcError: Error {
		case cannotConvert
		case noTag
		case noPath
	}
	
	private func showManual() {
		let manual = """
		- 해당 태그를 가진 노트들을 입력한 위치에 마크다운 형태로 가져오기
			bearc --outputPath path/to/directory --tags "public, press"
			bearc --outputPath . --tags public
			bearc -o path/to/directory -t "public, press"
		"""
		print(manual)
	}
	
	private func handleError(_ error: Error) {
		if let error = error as? BearcError {
			var message: String?
			switch error {
			case .cannotConvert:
				message = """
				Invalid input.
				Type `bearc help` for manual.
				"""
			case .noPath:
				message = "no path"
			case .noTag:
				message = "no tag"
			}
			print(message ?? "")
			return
		}
		print(error.localizedDescription)
	}
	
	private func convert(_ input: String) throws -> [String: String] {
		var result = [String: String]()
		let components = input.components(separatedBy: " ")
			.filter { $0.count != 0 }

		for index in stride(from: 0, to: components.endIndex, by: 2) {
			let keyString = components[index]
				.replacingOccurrences(of: "-", with: "")
			let value = components[index + 1]
			guard let key = CommandKey(rawValue: keyString) else { throw BearcError.cannotConvert }
			result[key.rawValue] = value
		}
		return result
	}
	
	private func convert(_ arguments: [String]) throws -> [String: String] {
		var result = [String: String]()
		let components = arguments.filter { $0.count != 0 }
		for index in stride(from: 0, to: components.endIndex, by: 2) {
			let keyString = components[index]
				.replacingOccurrences(of: "-", with: "")
			let value = components[index + 1]
			guard let key = CommandKey(rawValue: keyString) else { throw BearcError.cannotConvert }
			result[key.rawValue] = value
		}
		return result
	}

	
	func main(_ arguments: [String]) {
		let start = Date()
		guard arguments.count > 1 else {
			handleError(BearcError.cannotConvert)
			return
		}

		if arguments.firstIndex(of: "help") != nil {
			showManual()
			return
		}
		
		do {
			let dict = try convert(Array(arguments[1..<arguments.endIndex]))
			guard let tags = dict[CommandKey.tags.rawValue] else { throw BearcError.noTag }
			guard let outputPath = dict[CommandKey.outputPath.rawValue] else { throw BearcError.noPath }
			let components = tags
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.components(separatedBy: ",").filter { $0.count > 0 }
				.map { $0.trimmingCharacters(in: .whitespaces) }
			try Extractor().execute(
				with: components,
				into: URL(fileURLWithPath: outputPath)
			)
			let end = Date()
			print(end.timeIntervalSince(start))
		} catch {
			handleError(error)
			return
		}
	}
}

let extractor = InputHandler()
extractor.main(CommandLine.arguments)
