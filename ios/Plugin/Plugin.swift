import Foundation
import Capacitor
import SwiftKeychainWrapper

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(SecureStoragePlugin)
public class SecureStoragePlugin: CAPPlugin {
    
    @objc func set(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let value = call.getString("value") ?? ""
        let saveSuccessful: Bool = KeychainWrapper.standard.set(value, forKey: key)
        if(saveSuccessful) {
            call.success([
                "value": saveSuccessful
            ])
        }
        else {
            call.error("error")
        }
    }
    
    @objc func get(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let hasValue = KeychainWrapper.standard.hasValue(forKey: key)
        if(hasValue) {
            call.success([
                "value": KeychainWrapper.standard.string(forKey: key) ?? ""
            ])
        }
        else {
            call.error("Item with given key does not exist")
        }
    }
    
    @objc func remove(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: key)
        if(removeSuccessful) {
            call.success([
                "value": removeSuccessful
            ])
        }
        else {
            call.error("error")
        }
    }
    
    @objc func clear(_ call: CAPPluginCall) {
        let clearSuccessful: Bool = KeychainWrapper.standard.removeAllKeys()
        if(clearSuccessful) {
            call.success([
                "value": clearSuccessful
            ])
        }
        else {
            call.error("error")
        }
    }
    
    @objc func getPlatform(_ call: CAPPluginCall) {
        call.success([
            "value": "ios"
        ])
    }
}
