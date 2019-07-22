import Foundation
import Capacitor

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
        let maybeValue = KeychainWrapper.standard.string(forKey: key)
        if let value = maybeValue {
            call.success([
                "value": value
                ])
        }
        else {
            call.error("error")
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
}
