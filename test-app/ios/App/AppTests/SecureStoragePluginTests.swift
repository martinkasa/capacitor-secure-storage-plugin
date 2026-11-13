import XCTest
import Capacitor
@testable import CapacitorSecureStoragePlugin

/// Plugin methods tested with hand-built calls. Uses a test-only keychain service,
/// so the app's real data ("cap_sec") is never touched.
final class SecureStoragePluginTests: XCTestCase {
    private let keychain = Keychain(service: "cap_sec_plugin_tests")
    private var plugin: SecureStoragePlugin!

    override func setUpWithError() throws {
        try super.setUpWithError()
        try keychain.removeAll()
        plugin = SecureStoragePlugin()
        plugin.keychain = keychain
    }

    override func tearDownWithError() throws {
        try keychain.removeAll()
        plugin = nil
        try super.tearDownWithError()
    }

    func testSetThenGet() {
        XCTAssertEqual(resolved(plugin.set, ["key": "token", "value": "s3cret"]) as? Bool, true)
        XCTAssertEqual(resolved(plugin.get, ["key": "token"]) as? String, "s3cret")
    }

    func testGetMissingKeyRejects() {
        XCTAssertEqual(rejected(plugin.get, ["key": "missing"])?.message, SecureStoragePlugin.notFoundMessage)
    }

    /// A keychain failure must reach JS as the real error, not as "does not exist".
    func testGetKeychainFailureRejectsWithStatus() {
        let encodedKey = Data("binary".utf8)
        let item: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychain.service,
            kSecAttrAccount as String: encodedKey,
            kSecAttrGeneric as String: encodedKey,
            kSecAttrSynchronizable as String: false,
            kSecValueData as String: Data([0xFF, 0xFE])
        ]
        XCTAssertEqual(SecItemAdd(item as CFDictionary, nil), errSecSuccess)

        let error = rejected(plugin.get, ["key": "binary"])
        XCTAssertEqual(error?.code, String(errSecDecode))
        XCTAssertEqual(error?.message, KeychainError(status: errSecDecode).message)
    }

    func testKeys() throws {
        try keychain.set("1", forKey: "a")
        try keychain.set("2", forKey: "b")

        let keys = resolved(plugin.keys, [:]) as? [String]
        XCTAssertEqual(Set(keys ?? []), ["a", "b"])
    }

    func testRemove() throws {
        try keychain.set("value", forKey: "token")

        XCTAssertEqual(resolved(plugin.remove, ["key": "token"]) as? Bool, true)

        XCTAssertNil(try keychain.string(forKey: "token"))
    }

    func testRemoveMissingKeyRejects() {
        XCTAssertEqual(rejected(plugin.remove, ["key": "missing"])?.message, SecureStoragePlugin.notFoundMessage)
    }

    func testClearRemovesEverything() throws {
        try keychain.set("1", forKey: "a")
        try keychain.set("2", forKey: "b")

        XCTAssertEqual(resolved(plugin.clear, [:]) as? Bool, true)

        XCTAssertEqual(try keychain.allKeys(), [])
    }

    func testClearWhenEmptyResolves() {
        XCTAssertEqual(resolved(plugin.clear, [:]) as? Bool, true)
    }

    func testGetPlatform() {
        XCTAssertEqual(resolved(plugin.getPlatform, [:]) as? String, "ios")
    }

    // MARK: - Helpers

    private typealias Rejection = (message: String, code: String?)

    /// Runs a plugin method and returns the resolved `value`; fails the test if the call rejects.
    private func resolved(_ method: (CAPPluginCall) -> Void, _ options: [String: Any],
                          file: StaticString = #filePath, line: UInt = #line) -> Any? {
        let (value, error) = run(method, options)
        if let error { XCTFail("Rejected: \(error.message)", file: file, line: line) }
        return value
    }

    /// Runs a plugin method and returns the rejection; fails the test if the call resolves.
    private func rejected(_ method: (CAPPluginCall) -> Void, _ options: [String: Any],
                          file: StaticString = #filePath, line: UInt = #line) -> Rejection? {
        let (value, error) = run(method, options)
        if error == nil { XCTFail("Resolved unexpectedly with \(String(describing: value))", file: file, line: line) }
        return error
    }

    private func run(_ method: (CAPPluginCall) -> Void, _ options: [String: Any]) -> (Any?, Rejection?) {
        var value: Any?
        var error: Rejection?
        let call = CAPPluginCall(
            callbackId: "test",
            methodName: "test",
            options: options,
            success: { result, _ in value = result?.data?["value"] },
            error: { error = ($0?.message ?? "", $0?.code) }
        )
        method(call!)
        return (value, error)
    }
}
