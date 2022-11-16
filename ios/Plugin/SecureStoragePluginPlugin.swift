import Foundation
import Capacitor
import SwiftKeychainWrapper

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(SecureStoragePlugin)
public class SecureStoragePlugin: CAPPlugin {
    var keychainwrapper: KeychainWrapper = KeychainWrapper.init(serviceName: "cap_sec")
    
    @objc func set(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let value = call.getString("value") ?? ""
        let saveSuccessful: Bool = keychainwrapper.set(value, forKey: key, withAccessibility: .afterFirstUnlock)
        if(saveSuccessful) {
            call.resolve([
                "value": saveSuccessful
            ])
        }
        else {
            call.reject("error")
        }
    }
    
    @objc func get(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let hasValueDedicated = keychainwrapper.hasValue(forKey: key)
        let hasValueStandard = KeychainWrapper.standard.hasValue(forKey: key)
        
        // copy standard value to dedicated and remove standard key
        if (hasValueStandard && !hasValueDedicated) {
            let syncValueSuccessful: Bool = keychainwrapper.set(
                KeychainWrapper.standard.string(forKey: key) ?? "",
                forKey: key,
                withAccessibility: .afterFirstUnlock
            )
            let removeValueSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: key)
            if (!syncValueSuccessful || !removeValueSuccessful) {
                call.reject("error")
            }
        }
        
        if(hasValueDedicated || hasValueStandard) {
            call.resolve([
                "value": keychainwrapper.string(forKey: key) ?? ""
            ])
        }
        else {
            call.reject("Item with given key does not exist")
        }
    }
    
    @objc func keys(_ call: CAPPluginCall) {
        let keys = keychainwrapper.allKeys();
        call.resolve([
            "value": Array(keys)
        ])
    }
    
    @objc func remove(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let hasValueDedicated = keychainwrapper.hasValue(forKey: key)
        let hasValueStandard = KeychainWrapper.standard.hasValue(forKey: key)
        
        if(hasValueDedicated || hasValueStandard) {
            KeychainWrapper.standard.removeObject(forKey: key);
            let removeDedicatedSuccessful: Bool = keychainwrapper.removeObject(forKey: key)
            if(removeDedicatedSuccessful) {
                call.resolve([
                    "value": removeDedicatedSuccessful
                ])
            }
            else {
                call.reject("Remove failed")
            }
        }
        else {
            call.reject("Item with given key does not exist")
        }
    }
    
    @objc func clear(_ call: CAPPluginCall) {
        let keys = keychainwrapper.allKeys();
        // cleanup standard keychain wrapper keys
        
        if(keys.count == 0) {
            call.resolve([
                "value": true
            ])
        }
        else {            
            for key in keys {
                let hasValueStandard = KeychainWrapper.standard.hasValue(forKey: key)
                if (hasValueStandard) {
                    let removeStandardSuccessful = KeychainWrapper.standard.removeObject(forKey: key)
                    if (!removeStandardSuccessful) {
                        call.reject("error")
                    }
                }
            }
            
            let clearSuccessful: Bool = keychainwrapper.removeAllKeys()
            if(clearSuccessful) {
                call.resolve([
                    "value": clearSuccessful
                ])
            }
            else {
                call.reject("error")
            }
        }
    }
    
    @objc func getPlatform(_ call: CAPPluginCall) {
        call.resolve([
            "value": "ios"
        ])
    }
}
