//
//  Utils.swift
//  AtrooCapacitorSecureStoragePlugin
//
//  Created by Laszlo Blum on 2023. 10. 29..
//

import Foundation
import KeychainAccess

let defaultAccessibility = Accessibility.afterFirstUnlock

let keychainAccessibilityModeLookup = [
    "afterFirstUnlock": Accessibility.afterFirstUnlock,
    "afterFirstUnlockThisDeviceOnly": Accessibility.afterFirstUnlockThisDeviceOnly,
    "whenUnlocked": Accessibility.whenUnlocked,
    "whenUnlockedThisDeviceOnly": Accessibility.whenUnlockedThisDeviceOnly,
    "always": Accessibility.always,
    "alwaysThisDeviceOnly": Accessibility.alwaysThisDeviceOnly,
    "whenPasscodeSetThisDeviceOnly": Accessibility.whenPasscodeSetThisDeviceOnly
]

func lowercaseFirstCharacter(of string: String) -> String {
    guard !string.isEmpty else { return string }

    let firstIndex = string.startIndex
    let rest = string.index(after: firstIndex)..<string.endIndex

    let firstCharLowercased = string[firstIndex...firstIndex].lowercased()
    let remainingChars = string[rest]

    return firstCharLowercased + remainingChars
}

func getAccessibilityString(accessibility: Accessibility) -> String {
    return lowercaseFirstCharacter(of: accessibility.description)
}

