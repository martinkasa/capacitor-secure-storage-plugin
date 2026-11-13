import XCTest
import Capacitor
@testable import CapacitorSecureStoragePlugin

/// Plugin methods tested with hand-built calls. Uses test-only keychain services,
/// so the app's real data ("cap_sec" and the bundle-id legacy service) is never touched.
final class SecureStoragePluginTests: XCTestCase {
    private let keychain = Keychain(service: "cap_sec_plugin_tests")
    private let legacyKeychain = Keychain(service: "cap_sec_plugin_tests_legacy")
    private var plugin: SecureStoragePlugin!

    override func setUp() {
        super.setUp()
        _ = keychain.removeAll()
        _ = legacyKeychain.removeAll()
        plugin = SecureStoragePlugin()
        plugin.keychain = keychain
        plugin.legacyKeychain = legacyKeychain
    }

    override func tearDown() {
        _ = keychain.removeAll()
        _ = legacyKeychain.removeAll()
        plugin = nil
        super.tearDown()
    }

    func testSetThenGet() {
        XCTAssertEqual(resolved(plugin.set, ["key": "token", "value": "s3cret"]) as? Bool, true)
        XCTAssertEqual(resolved(plugin.get, ["key": "token"]) as? String, "s3cret")
    }

    func testGetMissingKeyRejects() {
        XCTAssertEqual(rejected(plugin.get, ["key": "missing"]), "Item with given key does not exist")
    }

    func testGetMigratesLegacyItem() {
        XCTAssertTrue(legacyKeychain.set("old", forKey: "token"))

        XCTAssertEqual(resolved(plugin.get, ["key": "token"]) as? String, "old")

        XCTAssertEqual(keychain.string(forKey: "token"), "old")
        XCTAssertFalse(legacyKeychain.hasValue(forKey: "token"))
    }

    func testGetPrefersDedicatedOverLegacy() {
        XCTAssertTrue(keychain.set("new", forKey: "token"))
        XCTAssertTrue(legacyKeychain.set("old", forKey: "token"))

        XCTAssertEqual(resolved(plugin.get, ["key": "token"]) as? String, "new")
    }

    func testKeys() {
        XCTAssertTrue(keychain.set("1", forKey: "a"))
        XCTAssertTrue(keychain.set("2", forKey: "b"))

        let keys = resolved(plugin.keys, [:]) as? [String]
        XCTAssertEqual(Set(keys ?? []), ["a", "b"])
    }

    func testRemoveDeletesDedicatedAndLegacy() {
        XCTAssertTrue(keychain.set("new", forKey: "token"))
        XCTAssertTrue(legacyKeychain.set("old", forKey: "token"))

        XCTAssertEqual(resolved(plugin.remove, ["key": "token"]) as? Bool, true)

        XCTAssertFalse(keychain.hasValue(forKey: "token"))
        XCTAssertFalse(legacyKeychain.hasValue(forKey: "token"))
    }

    func testRemoveMissingKeyRejects() {
        XCTAssertEqual(rejected(plugin.remove, ["key": "missing"]), "Item with given key does not exist")
    }

    func testClearRemovesEverythingIncludingLegacyDuplicates() {
        XCTAssertTrue(keychain.set("1", forKey: "a"))
        XCTAssertTrue(keychain.set("2", forKey: "b"))
        XCTAssertTrue(legacyKeychain.set("old", forKey: "a"))

        XCTAssertEqual(resolved(plugin.clear, [:]) as? Bool, true)

        XCTAssertEqual(keychain.allKeys(), [])
        XCTAssertFalse(legacyKeychain.hasValue(forKey: "a"))
    }

    func testClearWhenEmptyResolves() {
        XCTAssertEqual(resolved(plugin.clear, [:]) as? Bool, true)
    }

    func testGetPlatform() {
        XCTAssertEqual(resolved(plugin.getPlatform, [:]) as? String, "ios")
    }

    // MARK: - Helpers

    /// Runs a plugin method and returns the resolved `value`; fails the test if the call rejects.
    private func resolved(_ method: (CAPPluginCall) -> Void, _ options: [String: Any],
                          file: StaticString = #filePath, line: UInt = #line) -> Any? {
        let (value, error) = run(method, options)
        if let error { XCTFail("Rejected: \(error)", file: file, line: line) }
        return value
    }

    /// Runs a plugin method and returns the rejection message; fails the test if the call resolves.
    private func rejected(_ method: (CAPPluginCall) -> Void, _ options: [String: Any],
                          file: StaticString = #filePath, line: UInt = #line) -> String? {
        let (value, error) = run(method, options)
        if error == nil { XCTFail("Resolved unexpectedly with \(String(describing: value))", file: file, line: line) }
        return error
    }

    private func run(_ method: (CAPPluginCall) -> Void, _ options: [String: Any]) -> (Any?, String?) {
        var value: Any?
        var error: String?
        let call = CAPPluginCall(
            callbackId: "test",
            methodName: "test",
            options: options,
            success: { result, _ in value = result?.data?["value"] },
            error: { error = $0?.message ?? "" }
        )
        method(call!)
        return (value, error)
    }
}
