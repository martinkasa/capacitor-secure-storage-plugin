//
//  TmpValues.swift
//  AtrooCapacitorSecureStoragePlugin
//
//  Created by Laszlo Blum on 2023. 10. 29..
//

import Foundation
import KeychainAccess

struct TmpValues: Codable {
    var key: String
    var value: String
    var accessibility: Accessibility
    
    init(key: String, value: String, accessibility: Accessibility) {
        self.key = key
        self.value = value
        self.accessibility = accessibility
    }
    
    enum CodingKeys: String, CodingKey {
        case key
        case value
        case accessibility
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        value = try container.decode(String.self, forKey: .value)
        let accessibilityString = try container.decode(String.self, forKey: .accessibility)
        let accessibilityCandidate = keychainAccessibilityModeLookup[accessibilityString]
        if accessibilityCandidate != nil {
            accessibility = accessibilityCandidate!
        } else {
            accessibility = defaultAccessibility
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(value, forKey: .value)
        try container.encode(getAccessibilityString(accessibility: accessibility), forKey: .accessibility)
    }
}
