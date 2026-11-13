import Foundation
import Security

/// Minimal generic-password keychain store.
///
/// Items are stored in exactly the same shape SwiftKeychainWrapper used (account and generic
/// attributes as UTF-8 `Data`, value as UTF-8 bytes, non-synchronizable), so items written
/// by earlier plugin versions stay readable. Do not change the item shape without a migration.
struct Keychain {
    let service: String

    /// Location used by SwiftKeychainWrapper's `standard` instance in very old plugin versions.
    static let legacyStandard = Keychain(service: Bundle.main.bundleIdentifier ?? "SwiftKeychainWrapper")

    func set(_ value: String, forKey key: String) -> Bool {
        let data = Data(value.utf8)
        var query = itemQuery(forKey: key)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            query.removeValue(forKey: kSecValueData as String)
            let attributes = [kSecValueData as String: data]
            return SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecSuccess
        }
        return status == errSecSuccess
    }

    func string(forKey key: String) -> String? {
        var query = itemQuery(forKey: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func hasValue(forKey key: String) -> Bool {
        var query = itemQuery(forKey: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }

    func remove(forKey key: String) -> Bool {
        SecItemDelete(itemQuery(forKey: key) as CFDictionary) == errSecSuccess
    }

    func removeAll() -> Bool {
        SecItemDelete(serviceQuery() as CFDictionary) == errSecSuccess
    }

    func allKeys() -> [String] {
        var query = serviceQuery()
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitAll

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return []
        }
        return items.compactMap { item in
            (item[kSecAttrAccount as String] as? Data).flatMap { String(data: $0, encoding: .utf8) }
        }
    }

    private func serviceQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
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
