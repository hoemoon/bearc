//
//  URL.swift
//  BearKit
//
//  Created by hoemoon on 23/03/2019.
//

import Foundation

extension URL {
	static var tempURL: URL? {
		guard let supportDirectory = FileManager.default.urls(
			for: .applicationSupportDirectory,
			in: .userDomainMask).first else {
			return nil
		}
		return supportDirectory.appendingPathComponent("bearKit")
			.appendingPathComponent("generated")
	}
}
