//
//  Extractor.swift
//  Extractor
//
//  Created by hoemoon on 23/03/2019.
//

import Foundation
import SQLite

public struct Extractor {
	static var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
	
	public func execute(with tags: [String], into destination: URL) throws {
		let notes = try fetchNotes(with: tags)
		if !FileManager.default.fileExists(atPath: destination.path) {
			try FileManager.default.createDirectory(
				at: destination,
				withIntermediateDirectories: false
			)
		}
		for note in notes {
			try saveAsMarkdown(for: note, to: destination)
			try copyImages(for: note, to: destination)
		}
		print("\n\(notes.count) notes extracted.")
	}
	public init() {}
}

extension Extractor {
	private func fetchNotes(with tags: [String]) throws -> [Note] {
		guard let db = try? Connection(URL.bearContainerURL.absoluteString, readonly: true) else {
			fatalError("db connection failed.")
		}
		guard let rows = try? db.prepare(Table("ZSFNOTE")) else {
			fatalError("row prepare failed.")
		}
		
		return rows.compactMap { $0.notify(with: tags) }
	}
	
	private func saveAsMarkdown(for note: Note, to destination: URL) throws {
		try note.save(to: destination)
	}
	
	private func copyImages(for note: Note, to destination: URL) throws {
		guard let infos = note.imageInfos else {
			fatalError("failed to extract meta info.")
		}
		for item in infos {
			let (imageFileName, imageURL) = item
			let destinationURL = destination.appendingPathComponent("\(imageFileName)")
			if FileManager.default.fileExists(atPath: destinationURL.path) {
				try FileManager.default.removeItem(at: destinationURL)
			}
			try FileManager.default.copyItem(at: imageURL, to: destinationURL)
			print(destinationURL.path)
		}
	}
}

private extension URL {
	static var bearContainerURL: URL {
		return URL(
			fileURLWithPath: "Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/database.sqlite",
			relativeTo: FileManager.default.homeDirectoryForCurrentUser)
	}
}

