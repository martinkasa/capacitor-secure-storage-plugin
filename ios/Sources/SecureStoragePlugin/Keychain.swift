import Foundation
import Security

/// Keychain operation failed for a reason other than a missing item,
/// e.g. `errSecInteractionNotAllowed` when the device was not unlocked since reboot.
struct KeychainError: Error {
    let status: OSStatus

    var message: String {
        let description = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
        return "Keychain error \(status): \(description)"
    }
}

/// Minimal generic-password keychain store.
///
/// Items are stored in exactly the same shape SwiftKeychainWrapper used (account and generic
/// attributes as UTF-8 `Data`, value as UTF-8 bytes, non-synchronizable), so items written
/// by earlier plugin versions stay readable. Do not change the item shape without a migration.
///
/// Missing items are reported by `nil` / `false`; every other failure throws `KeychainError`.
struct Keychain {
    let service: String

    func set(_ value: String, forKey key: String) throws {
        let attributes: [String: Any] = [
            kSecValueData as String: Data(value.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let query = itemQuery(forKey: key)

        var status = SecItemAdd(query.merging(attributes) { $1 } as CFDictionary, nil)
        if status == errSecDuplicateItem {
            // Accessibility must not be part of the match, otherwise items stored with
            // a different accessibility by older versions could never be overwritten.
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        }
        try check(status)
    }

    func string(forKey key: String) throws -> String? {
        var query = itemQuery(forKey: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        try check(status)
        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else {
            throw KeychainError(status: errSecDecode)
        }
        return value
    }

    /// Returns `false` when there was nothing to remove.
    func remove(forKey key: String) throws -> Bool {
        let status = SecItemDelete(itemQuery(forKey: key) as CFDictionary)
        if status == errSecItemNotFound {
            return false
        }
        try check(status)
        return true
    }

    func removeAll() throws {
        let status = SecItemDelete(serviceQuery() as CFDictionary)
        if status != errSecItemNotFound {
            try check(status)
        }
    }

    func allKeys() throws -> [String] {
        var query = serviceQuery()
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitAll

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return []
        }
        try check(status)
        let items = result as? [[String: Any]] ?? []
        return items.compactMap { item in
            (item[kSecAttrAccount as String] as? Data).flatMap { String(data: $0, encoding: .utf8) }
        }
    }

    private func check(_ status: OSStatus) throws {
        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    private func serviceQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
    }

    private func itemQuery(forKey key: String) -> [String: Any] {
        let encodedKey = Data(key.utf8)
        var query = serviceQuery()
        query[kSecAttrAccount as String] = encodedKey
        query[kSecAttrGeneric as String] = encodedKey
        query[kSecAttrSynchronizable as String] = false
        return query
    }
}
