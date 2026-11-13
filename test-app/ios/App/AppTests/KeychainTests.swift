import XCTest
@testable import CapacitorSecureStoragePlugin

final class KeychainTests: XCTestCase {
    private let keychain = Keychain(service: "cap_sec_tests")

    override func setUp() {
        super.setUp()
        _ = keychain.removeAll()
    }

    override func tearDown() {
        _ = keychain.removeAll()
        super.tearDown()
    }

    func testSetAndGet() {
        XCTAssertTrue(keychain.set("Hello, World!", forKey: "key"))
        XCTAssertEqual(keychain.string(forKey: "key"), "Hello, World!")
        XCTAssertTrue(keychain.hasValue(forKey: "key"))
    }

    func testSetOverwritesExistingValue() {
        XCTAssertTrue(keychain.set("first", forKey: "key"))
        XCTAssertTrue(keychain.set("second", forKey: "key"))
        XCTAssertEqual(keychain.string(forKey: "key"), "second")
        XCTAssertEqual(keychain.allKeys(), ["key"])
    }

    func testUnicodeAndEmptyValues() {
        XCTAssertTrue(keychain.set("žluťoučký kůň 🐴", forKey: "klíč"))
        XCTAssertTrue(keychain.set("", forKey: "empty"))
        XCTAssertEqual(keychain.string(forKey: "klíč"), "žluťoučký kůň 🐴")
        XCTAssertEqual(keychain.string(forKey: "empty"), "")
        XCTAssertEqual(Set(keychain.allKeys()), ["klíč", "empty"])
    }

    func testMissingKey() {
        XCTAssertNil(keychain.string(forKey: "missing"))
        XCTAssertFalse(keychain.hasValue(forKey: "missing"))
        XCTAssertFalse(keychain.remove(forKey: "missing"))
    }

    func testRemove() {
        XCTAssertTrue(keychain.set("value", forKey: "key"))
        XCTAssertTrue(keychain.remove(forKey: "key"))
        XCTAssertNil(keychain.string(forKey: "key"))
    }

    func testRemoveAllOnlyTouchesOwnService() {
        let other = Keychain(service: "cap_sec_tests_other")
        defer { _ = other.removeAll() }
        XCTAssertTrue(other.set("keep", forKey: "key"))
        XCTAssertTrue(keychain.set("a", forKey: "a"))
        XCTAssertTrue(keychain.set("b", forKey: "b"))

        XCTAssertTrue(keychain.removeAll())

        XCTAssertEqual(keychain.allKeys(), [])
        XCTAssertEqual(other.string(forKey: "key"), "keep")
    }

    /// Items written by plugin versions <= 0.13 (via SwiftKeychainWrapper) must stay readable.
    /// If this fails, existing users lose their stored values after upgrading.
    func testReadsItemsInSwiftKeychainWrapperFormat() {
        let encodedKey = Data("token".utf8)
        let legacyItem: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "cap_sec_tests",
            kSecAttrAccount as String: encodedKey,
            kSecAttrGeneric as String: encodedKey,
            kSecAttrSynchronizable as String: false,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: Data("s3cret".utf8)
        ]
        XCTAssertEqual(SecItemAdd(legacyItem as CFDictionary, nil), errSecSuccess)

        XCTAssertEqual(keychain.string(forKey: "token"), "s3cret")
        XCTAssertEqual(keychain.allKeys(), ["token"])
        XCTAssertTrue(keychain.set("updated", forKey: "token"))
        XCTAssertEqual(keychain.string(forKey: "token"), "updated")
        XCTAssertEqual(keychain.allKeys(), ["token"])
        XCTAssertTrue(keychain.remove(forKey: "token"))
    }

    /// New items must keep the SwiftKeychainWrapper shape (account as UTF-8 `Data`), otherwise
    /// `allKeys()` and plugin versions <= 0.13 (after a downgrade) would not list them.
    func testWritesItemsInSwiftKeychainWrapperFormat() throws {
        XCTAssertTrue(keychain.set("s3cret", forKey: "token"))

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "cap_sec_tests",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        XCTAssertEqual(SecItemCopyMatching(query as CFDictionary, &result), errSecSuccess)
        let item = try XCTUnwrap(result as? [String: Any])

        XCTAssertEqual(item[kSecAttrAccount as String] as? Data, Data("token".utf8))
        XCTAssertEqual(item[kSecAttrGeneric as String] as? Data, Data("token".utf8))
        XCTAssertEqual(item[kSecValueData as String] as? Data, Data("s3cret".utf8))
        XCTAssertEqual(item[kSecAttrAccessible as String] as? String, kSecAttrAccessibleAfterFirstUnlock as String)
    }
}
