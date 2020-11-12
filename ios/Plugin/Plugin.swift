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
        call.success([
            "value": saveSuccessful
        ])
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
        
        call.success([
            "value": keychainwrapper.string(forKey: key) ?? ""
        ])
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
        call.success([
            "value": removeDedicatedSuccessful
        ])
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
        call.success([
            "value": clearSuccessful
        ])
    }
    
    @objc func getPlatform(_ call: CAPPluginCall) {
        call.success([
            "value": "ios"
        ])
    }
}