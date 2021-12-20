//
//  String.Quickstart.swift
//  Quickstart
//
//  Created by Jaesung Lee on 2021/12/20.
//

import Foundation

extension String {
    public var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var isEmptyOrWhitespace: Bool {
        return trimmed.isEmpty
    }
    
    public var collapsed: String? {
        if isEmptyOrWhitespace {
            return nil
        } else {
            return trimmed
        }
    }
}
