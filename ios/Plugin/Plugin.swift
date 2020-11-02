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
        let saveSuccessful: Bool = keychainwrapper.set(value, forKey: key)
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
        let hasValueDedicated = keychainwrapper.hasValue(forKey: key)
        let hasValueStandard = KeychainWrapper.standard.hasValue(forKey: key)
        
        // copy standard value to dedicated and remove standard key
        if (hasValueStandard && !hasValueDedicated) {
            let syncValueSuccessful: Bool = keychainwrapper.set(
                KeychainWrapper.standard.string(forKey: key) ?? "",
                forKey: key
            )
            let removeValueSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: key)
            if (!syncValueSuccessful || !removeValueSuccessful) {
                call.error("error")
            }
        }
        
        if(hasValueDedicated || hasValueStandard) {
            call.success([
                "value": keychainwrapper.string(forKey: key) ?? ""
            ])
        }
        else {
            call.error("Item with given key does not exist")
        }
    }
    
    @objc func keys(_ call: CAPPluginCall) {
        let keys = keychainwrapper.allKeys();
        call.success([
            "value": keys
        ])
    }
    
    @objc func remove(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        KeychainWrapper.standard.removeObject(forKey: key);
        let removeDedicatedSuccessful: Bool = keychainwrapper.removeObject(forKey: key)
        if(removeDedicatedSuccessful) {
            call.success([
                "value": removeDedicatedSuccessful
            ])
        }
        else {
            call.error("error")
        }
    }
    
    @objc func clear(_ call: CAPPluginCall) {
        let keys = keychainwrapper.allKeys();
        // cleanup standard keychain wrapper keys
        for key in keys {
            let hasValueStandard = KeychainWrapper.standard.hasValue(forKey: key)
            if (hasValueStandard) {
                let removeStandardSuccessful = KeychainWrapper.standard.removeObject(forKey: key)
                if (!removeStandardSuccessful) {
                    call.error("error")
                }
            }
        }
        
        let clearSuccessful: Bool = keychainwrapper.removeAllKeys()
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
