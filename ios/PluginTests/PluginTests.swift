import XCTest
import Capacitor
import SwiftKeychainWrapper

@testable import Plugin

class PluginTests: XCTestCase {
    
    func testSet() {
        let key = "key"
        let value = "Hello, World!"
        let valueModified = "Modified"
        let keychainwrapper = KeychainWrapper.init(serviceName: "cap_sec")
        KeychainWrapper.standard.set(value, forKey: key)
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
            "value": valueModified
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? Bool
                XCTAssertTrue(resultValue ?? false)
                // dedicated keychain wrapper
                let dedicatedValue = keychainwrapper.string(forKey: key)
                XCTAssertEqual(valueModified, dedicatedValue)
                // standard keychain wrapper should not be modified
                let standardValue = KeychainWrapper.standard.string(forKey: key)
                XCTAssertEqual(value, standardValue)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        
        plugin.set(call!)
    }
    
    func testGet() {
        let key = "key"
        let value = "Hello, World!"
        let keychainwrapper = KeychainWrapper.init(serviceName: "cap_sec")
        keychainwrapper.set(value, forKey: key)
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? String
                XCTAssertEqual(value, resultValue)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        
        plugin.get(call!)
    }
    
    func testGetStandard() {
        let key = "key"
        let value = "Hello, World!"
        KeychainWrapper.standard.set(value, forKey: key)
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? String
                XCTAssertEqual(value, resultValue)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        
        plugin.get(call!)
    }
    
    func testKeys() {
        let key = "key"
        let value = "value"
        
        let plugin = SecureStoragePlugin()
        
        let keychainwrapper = KeychainWrapper.init(serviceName: "cap_sec")
        keychainwrapper.set(value, forKey: key)
        
        
        let callOne = CAPPluginCall(callbackId: "testOne", options: [
            "key": key
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? Set<String>
                XCTAssertEqual(1, resultValue!.count)
                XCTAssertEqual(key, resultValue!.first)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        plugin.keys(callOne!)
    }
    
    func testNonExistingGet() {
        let key = "keyNonExisting"
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key
            ], success: { (result, call) in
                XCTFail("Error shouldn't have been called")
        }, error: { (err) in
            XCTAssertNotNil(err)
        })
        
        plugin.get(call!)
    }
    
    func testRemove() {
        let key = "key"
        let value = "Hello, World!"
        // prefill dedicated keychain wrapper
        let keychainwrapper = KeychainWrapper.init(serviceName: "cap_sec")
        keychainwrapper.set(value, forKey: key)
        // prefill standard keychain wrapper
        KeychainWrapper.standard.set(value, forKey: key)
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? Bool
                XCTAssertTrue(resultValue ?? false)
                // dedicated keychain wrapper
                let dedicatedValue = keychainwrapper.string(forKey: key)
                XCTAssertNil(dedicatedValue)
                // standard keychain wrapper should not be modified
                let standardValue = KeychainWrapper.standard.string(forKey: key)
                XCTAssertEqual(value, standardValue)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        
        plugin.remove(call!)
    }
    
    func testClear() {
        let key = "key"
        let value = "Hello, World!"
        // prefill dedicated keychain wrapper
        let keychainwrapper = KeychainWrapper.init(serviceName: "cap_sec")
        keychainwrapper.set(value, forKey: key)
        keychainwrapper.set(value + "2", forKey: key + "2")
        // prefill standard keychain wrapper
        KeychainWrapper.standard.set(value, forKey: key)
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? Bool
                XCTAssertTrue(resultValue ?? false)
                // dedicated keychain wrapper
                let dedicatedValue = keychainwrapper.string(forKey: key)
                XCTAssertNil(dedicatedValue)
                let dedicatedValue2 = keychainwrapper.string(forKey: key + "2")
                XCTAssertNil(dedicatedValue2)
                // standard keychain wrapper should not be modified
                let standardValue = KeychainWrapper.standard.string(forKey: key)
                XCTAssertNotNil(standardValue)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        
        plugin.clear(call!)
    }
    
    func testGetPlatform() {
        let plugin = SecureStoragePlugin()
        let call = CAPPluginCall(callbackId: "test",
                                 success: { (result, call) in
                let resultValue = result!.data["value"] as? String
                XCTAssertEqual("ios", resultValue)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        
        plugin.getPlatform(call!)
    }
}
