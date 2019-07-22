import XCTest
import Capacitor

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
}
