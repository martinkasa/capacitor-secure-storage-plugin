import XCTest
@testable import CapacitorSecureStoragePlugin

final class KeychainTests: XCTestCase {
    private let keychain = Keychain(service: "cap_sec_tests")

    override func setUpWithError() throws {
        try super.setUpWithError()
        try keychain.removeAll()
    }

    override func tearDownWithError() throws {
        try keychain.removeAll()
        try super.tearDownWithError()
    }

    func testSetAndGet() throws {
        try keychain.set("Hello, World!", forKey: "key")
        XCTAssertEqual(try keychain.string(forKey: "key"), "Hello, World!")
    }

    func testSetOverwritesExistingValue() throws {
        try keychain.set("first", forKey: "key")
        try keychain.set("second", forKey: "key")
        XCTAssertEqual(try keychain.string(forKey: "key"), "second")
        XCTAssertEqual(try keychain.allKeys(), ["key"])
    }

    func testUnicodeAndEmptyValues() throws {
        try keychain.set("žluťoučký kůň 🐴", forKey: "klíč")
        try keychain.set("", forKey: "empty")
        XCTAssertEqual(try keychain.string(forKey: "klíč"), "žluťoučký kůň 🐴")
        XCTAssertEqual(try keychain.string(forKey: "empty"), "")
        XCTAssertEqual(Set(try keychain.allKeys()), ["klíč", "empty"])
    }

    func testMissingKey() throws {
        XCTAssertNil(try keychain.string(forKey: "missing"))
        XCTAssertFalse(try keychain.remove(forKey: "missing"))
        XCTAssertEqual(try keychain.allKeys(), [])
        XCTAssertNoThrow(try keychain.removeAll(), "removeAll on an empty service is not a failure")
    }

    func testRemove() throws {
        try keychain.set("value", forKey: "key")
        XCTAssertTrue(try keychain.remove(forKey: "key"))
        XCTAssertNil(try keychain.string(forKey: "key"))
    }

    func testRemoveAllOnlyTouchesOwnService() throws {
        let other = Keychain(service: "cap_sec_tests_other")
        defer { try? other.removeAll() }
        try other.set("keep", forKey: "key")
        try keychain.set("a", forKey: "a")
        try keychain.set("b", forKey: "b")

        try keychain.removeAll()

        XCTAssertEqual(try keychain.allKeys(), [])
        XCTAssertEqual(try other.string(forKey: "key"), "keep")
    }

    func testUndecodableValueThrowsInsteadOfReportingMissing() throws {
        try addRawItem(forKey: "binary", value: Data([0xFF, 0xFE]))

        XCTAssertThrowsError(try keychain.string(forKey: "binary")) { error in
            XCTAssertEqual((error as? KeychainError)?.status, errSecDecode)
        }
    }

    func testErrorMessageContainsStatus() {
        let message = KeychainError(status: errSecInteractionNotAllowed).message
        XCTAssertTrue(message.hasPrefix("Keychain error -25308: "), message)
    }

    /// Items written by plugin versions <= 0.13 (via SwiftKeychainWrapper) must stay readable.
    /// If this fails, existing users lose their stored values after upgrading.
    func testReadsItemsInSwiftKeychainWrapperFormat() throws {
        try addRawItem(forKey: "token", value: Data("s3cret".utf8))

        XCTAssertEqual(try keychain.string(forKey: "token"), "s3cret")
        XCTAssertEqual(try keychain.allKeys(), ["token"])
        try keychain.set("updated", forKey: "token")
        XCTAssertEqual(try keychain.string(forKey: "token"), "updated")
        XCTAssertEqual(try keychain.allKeys(), ["token"])
        XCTAssertTrue(try keychain.remove(forKey: "token"))
    }

    /// New items must keep the SwiftKeychainWrapper shape (account as UTF-8 `Data`), otherwise
    /// `allKeys()` and plugin versions <= 0.13 (after a downgrade) would not list them.
    func testWritesItemsInSwiftKeychainWrapperFormat() throws {
        try keychain.set("s3cret", forKey: "token")

        let item = try storedItem()
        XCTAssertEqual(item[kSecAttrAccount as String] as? Data, Data("token".utf8))
        XCTAssertEqual(item[kSecAttrGeneric as String] as? Data, Data("token".utf8))
        XCTAssertEqual(item[kSecValueData as String] as? Data, Data("s3cret".utf8))
        XCTAssertEqual(item[kSecAttrAccessible as String] as? String, kSecAttrAccessibleAfterFirstUnlock as String)
    }

    /// Items stored with another accessibility (e.g. by old plugin versions) must still be
    /// overwritable, and get upgraded to the current accessibility on write.
    func testOverwritesItemWithDifferentAccessibility() throws {
        try addRawItem(forKey: "token", value: Data("old".utf8), accessible: kSecAttrAccessibleWhenUnlocked)

        try keychain.set("new", forKey: "token")

        XCTAssertEqual(try keychain.string(forKey: "token"), "new")
        XCTAssertEqual(try keychain.allKeys(), ["token"])
        let item = try storedItem()
        XCTAssertEqual(item[kSecAttrAccessible as String] as? String, kSecAttrAccessibleAfterFirstUnlock as String)
    }

    // MARK: - Helpers

    /// Adds an item in SwiftKeychainWrapper's shape directly via Security APIs.
    private func addRawItem(forKey key: String, value: Data,
                            accessible: CFString = kSecAttrAccessibleAfterFirstUnlock) throws {
        let encodedKey = Data(key.utf8)
        let item: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychain.service,
            kSecAttrAccount as String: encodedKey,
            kSecAttrGeneric as String: encodedKey,
            kSecAttrSynchronizable as String: false,
            kSecAttrAccessible as String: accessible,
            kSecValueData as String: value
        ]
        XCTAssertEqual(SecItemAdd(item as CFDictionary, nil), errSecSuccess)
    }

    private func storedItem() throws -> [String: Any] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychain.service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        XCTAssertEqual(SecItemCopyMatching(query as CFDictionary, &result), errSecSuccess)
        return try XCTUnwrap(result as? [String: Any])
    }
}
