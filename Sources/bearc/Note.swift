//
//  Note.swift
//  BearKit
//
//  Created by hoemoon on 23/03/2019.
//

import Foundation
import Yams

struct Note {
	typealias ImageID = String
	typealias ImageLocation = URL
	typealias ImageInfo = (ImageID, ImageLocation)

	let id: String
	let createdAt: Date
	let modifiedAt: Date
	let content: String
	let searchedTags: [String]
	
	enum AttributeKey: String {
		case id
		case createdAt
		case modifiedAt
		case title
		case summary
		case slug
		case images
	}
}

extension Note {
	func save(to url: URL) throws {
		let fileURL = url.appendingPathComponent("\(id).md")
		let markdown = try asMarkdown()
		if FileManager.default.fileExists(atPath: fileURL.path) {
			try FileManager.default.removeItem(at: fileURL)
		}
		try markdown.write(
			to: fileURL,
			atomically: true,
			encoding: .utf8
		)
	}
	
	var imageInfos: [ImageInfo]? {
		let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
		guard let regex = try? NSRegularExpression(pattern: "\\[image:([^//]+)\\/([^//]+)\\]", options: []) else { return nil }
		
		return regex.matches(in: content, options: [], range: nsRange)
			.map { (Range($0.range(at: 1), in: content), Range($0.range(at: 2), in: content)) }
			.filter { $0.0 != nil && $0.1 != nil }
			.map {
				let (imageIDRange, imageNameRange) = ($0.0!, $0.1!)
				let imageID = String(content[imageIDRange])
				let imageName = String(content[imageNameRange])
				let imageURL = URL(
					fileURLWithPath: "\(String.imagePath)\(imageID + "/" + imageName)",
					relativeTo: FileManager.default.homeDirectoryForCurrentUser
				)
				return ("\(id)-\(imageName)", imageURL)
		}
	}
	
	private var replacedContent: String? {
		// TODO: 태그 공백으로 교체하는 로직 수정하기
		let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
		guard let imageRegex = try? NSRegularExpression(pattern: "\\[image:([^\\]]+)\\/([^\\]]+)\\]", options: []) else { return nil }
		let replaced = imageRegex.stringByReplacingMatches(
			in: content,
			options: [],
			range: nsRange,
			withTemplate: "![](\(id)$2)"
			).replacingOccurrences(
				of: #"```yaml([\s\S]+)```"#,
				with: "",
				options: .regularExpression
			).replacingOccurrences(
				of: #"#[\w\/]+"#,
				with: "",
				options: .regularExpression
		)
		return replaced.trimmingCharacters(in: .newlines)
	}

	private func encodedYaml() -> Yams.Node? {
		let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
		guard let regex = try? NSRegularExpression(pattern: #"```yaml([\s\S]+)```"#, options: []) else { return nil }
		let raw = regex.matches(in: content, options: [], range: nsRange)
			.compactMap { Range($0.range(at: 1), in: content) }
			.map { String(content[$0]) }
			.first
		guard let unwrapped = raw else { return nil }
		guard let node = try? Yams.compose(yaml: unwrapped) else { return nil }
		return node
	}
	
	private func asMarkdown() throws -> String {
		guard let content = replacedContent else {
			fatalError()
		}
		var result = "```yaml\n"
		if var encoded = encodedYaml() {
			encoded[AttributeKey.id.rawValue] = Node(id)
			encoded[AttributeKey.createdAt.rawValue] = Node(Extractor.dateFormatter.string(from: createdAt))
			encoded[AttributeKey.createdAt.rawValue] = Node(Extractor.dateFormatter.string(from: modifiedAt))
			if let imageInfos = imageInfos {
				encoded[AttributeKey.images.rawValue] = try Node(imageInfos.map { $0.0 })
			}
			result += try Yams.serialize(node: encoded)
			result += "```\n\n"
		}
		result += content
		return result
	}
}

private extension String {
	static var imagePath: String {
		return "Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/Local Files/Note Images/"
	}
}
