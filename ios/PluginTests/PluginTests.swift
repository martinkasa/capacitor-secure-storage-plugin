import XCTest
import Capacitor
import SwiftKeychainWrapper

@testable import Plugin

class PluginTests: XCTestCase {
    
    func testSet() {
        let key = "key"
        let value = "Hello, World!"
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
            "value": value
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? Bool
                XCTAssertTrue(resultValue ?? false)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        
        plugin.set(call!)
    }
    
    func testGet() {
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
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key,
            "value": value
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? Bool
                XCTAssertTrue(resultValue ?? false)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        plugin.set(call!)
        
        
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
        KeychainWrapper.standard.set(value, forKey: key)
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? Bool
                XCTAssertTrue(resultValue ?? false)
                let maybeValue = KeychainWrapper.standard.string(forKey: key)
                XCTAssertNil(maybeValue)
        }, error: { (err) in
            XCTFail("Error shouldn't have been called")
        })
        
        plugin.remove(call!)
    }
    
    func testClear() {
        let key = "key"
        let value = "Hello, World!"
        KeychainWrapper.standard.set(value, forKey: key)
        KeychainWrapper.standard.set(value + "2", forKey: key + "2")
        
        let plugin = SecureStoragePlugin()
        
        let call = CAPPluginCall(callbackId: "test", options: [
            "key": key
            ], success: { (result, call) in
                let resultValue = result!.data["value"] as? Bool
                XCTAssertTrue(resultValue ?? false)
                let maybeValue = KeychainWrapper.standard.string(forKey: key)
                XCTAssertNil(maybeValue)
                let maybeValue2 = KeychainWrapper.standard.string(forKey: key + "2")
                XCTAssertNil(maybeValue2)
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
