//
//  Row.swift
//  BearKit
//
//  Created by hoemoon on 04/04/2019.
//

import Foundation
import SQLite

extension Row {
	var creationDate: Date? {
		let expression = Expression<Double?>("ZCREATIONDATE")
		guard let double = self[expression] else { return nil }
		return Date(timeIntervalSinceReferenceDate: double)
	}
	var modificationDate: Date? {
		let expression = Expression<Double?>("ZMODIFICATIONDATE")
		guard let double = self[expression] else { return nil }
		return Date(timeIntervalSinceReferenceDate: double)
	}
	var isTrash: Bool {
		return self[Expression<Double?>("ZTRASHEDDATE")] != nil
	}
	var content: String? {
		let expression = Expression<String?>("ZTEXT")
		guard let string = self[expression] else { return nil }
		return string
	}
	var id: String {
		return self[Expression<String>("ZUNIQUEIDENTIFIER")]
	}

	func notify(with tags: [String]) -> Note? {
		guard let content = content,
			let createdAt = creationDate,
			let modifiedAt = modificationDate,
			!isTrash else { return nil }
		for tag in tags {
			if content.contains("#\(tag)") {
				return Note(
					id: id,
					createdAt: createdAt,
					modifiedAt: modifiedAt,
					content: content,
					searchedTags: tags
				)
			}
		}
		return nil
	}
}
