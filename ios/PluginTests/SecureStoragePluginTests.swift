import Capacitor
import SimpleKeychain
import XCTest

@testable import Plugin

class PluginTests: XCTestCase {

    func setupDedicatedKeychain(_ service: String) -> SimpleKeychain {
        let keychain = SimpleKeychain(service: service)
        try? keychain.deleteAll()
        return keychain
    }

    func testSet() {
        let key = "key"
        let value = "Modified"

        let plugin = SecureStoragePlugin()

        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
            "value": value,
        ], success: { result, _ in
            let resultValue = result!.data?["value"] as? Bool
            XCTAssertEqual(resultValue, true)
        }, error: { _ in
            XCTFail("Error shouldn't have been called")
        })

        plugin.set(call!)
    }

    func testGet() {
        let key = "key"
        let value = "Hello, World!"

        let keychain = self.setupDedicatedKeychain("cap_sec")
        try? keychain.set(value, forKey: key)

        let plugin = SecureStoragePlugin()

        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
        ], success: { result, _ in
            let resultValue = result!.data?["value"] as? String
            XCTAssertEqual(value, resultValue)
        }, error: { _ in
            XCTFail("Error shouldn't have been called")
        })

        plugin.get(call!)
    }

    func testKeys() {
        let key = "key"
        let key2 = "key2"
        let value = "value"

        let keychain = self.setupDedicatedKeychain("cap_sec")
        try? keychain.set(value, forKey: key)
        try? keychain.set(value, forKey: key2)

        let plugin = SecureStoragePlugin()

        let callOne = CAPPluginCall(
            callbackId: "test",
            options: [:],
            success: { result, _ in
                let resultValue = result!.data?["value"] as? [String]
                XCTAssertEqual(2, resultValue!.count)
                XCTAssertTrue(resultValue!.contains(key))
                XCTAssertTrue(resultValue!.contains(key2))
            },
            error: { _ in
                XCTFail("Error shouldn't have been called")
            }
        )
        plugin.keys(callOne!)
    }

    func testNonExistingGet() {
        let key = "keyNonExisting"

        let keychain = self.setupDedicatedKeychain("cap_sec")
        try? keychain.deleteAll()

        let plugin = SecureStoragePlugin()

        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
        ], success: { _, _ in
            XCTFail("Error shouldn't have been called")
        }, error: { err in
            XCTAssertNotNil(err)
        })

        plugin.get(call!)
    }

    func testNonExistingRemove() {
        let key = "keyNonExisting"

        let keychain = self.setupDedicatedKeychain("cap_sec")
        try? keychain.deleteAll()

        let plugin = SecureStoragePlugin()

        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
        ], success: { _, _ in
            XCTFail("Error shouldn't have been called")
        }, error: { err in
            XCTAssertNotNil(err)
        })

        plugin.remove(call!)
    }

    func testRemove() {
        let key = "key"
        let value = "Hello, World!"

        let keychain = self.setupDedicatedKeychain("cap_sec")
        try? keychain.set(value, forKey: key)

        let plugin = SecureStoragePlugin()

        // Remove key after setting
        var call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
        ], success: { result, _ in
            XCTAssertNotNil(result)
        }, error: { _ in
            XCTFail("Error shouldn't have been called")
        })

        plugin.remove(call!)

        // Remove already removed key
        call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
        ], success: { _, _ in
            XCTFail("Error shouldn't have been called")
        }, error: { err in
            XCTAssertNotNil(err)
        })

        plugin.remove(call!)
    }

    func testClear() {
        let key = "key"
        let value = "Hello, World!"

        let keychain = self.setupDedicatedKeychain("cap_sec")
        try? keychain.set(value, forKey: key)
        try? keychain.set(value + "2", forKey: key + "2")

        let plugin = SecureStoragePlugin()

        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
        ], success: { _, _ in
            let dedicatedValue = try? keychain.string(forKey: key)
            XCTAssertNil(dedicatedValue)

            let dedicatedValue2 = try? keychain.string(forKey: key + "2")
            XCTAssertNil(dedicatedValue2)
        }, error: { _ in
            XCTFail("Error shouldn't have been called")
        })

        plugin.clear(call!)
    }

    func testGetPlatform() {
        let plugin = SecureStoragePlugin()
        let call = CAPPluginCall(
            callbackId: "test",
            success: { result, _ in
                let resultValue = result!.data?["value"] as? String
                XCTAssertEqual("ios", resultValue)
            },
            error: { _ in
                XCTFail("Error shouldn't have been called")
            }
        )

        plugin.getPlatform(call!)
    }
}
