import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(SecureStoragePlugin)
public class SecureStoragePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SecureStoragePlugin"
    public let jsName = "SecureStoragePlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "set", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "get", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "keys", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "remove", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clear", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPlatform", returnType: CAPPluginReturnPromise)
    ]
    // `var` so tests can point the plugin at test-only keychain services.
    var keychain = Keychain(service: "cap_sec")
    var legacyKeychain = Keychain.legacyStandard

    @objc func set(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let value = call.getString("value") ?? ""
        if keychain.set(value, forKey: key) {
            call.resolve(["value": true])
        } else {
            call.reject("error")
        }
    }

    @objc func get(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let hasValueDedicated = keychain.hasValue(forKey: key)
        let hasValueLegacy = legacyKeychain.hasValue(forKey: key)

        if hasValueLegacy && !hasValueDedicated {
            let migrated = keychain.set(legacyKeychain.string(forKey: key) ?? "", forKey: key)
            let removed = legacyKeychain.remove(forKey: key)
            if !migrated || !removed {
                call.reject("error")
                return
            }
        }

        if hasValueDedicated || hasValueLegacy {
            call.resolve(["value": keychain.string(forKey: key) ?? ""])
        } else {
            call.reject("Item with given key does not exist")
        }
    }

    @objc func keys(_ call: CAPPluginCall) {
        call.resolve(["value": keychain.allKeys()])
    }

    @objc func remove(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let hasValueDedicated = keychain.hasValue(forKey: key)
        let hasValueLegacy = legacyKeychain.hasValue(forKey: key)

        guard hasValueDedicated || hasValueLegacy else {
            call.reject("Item with given key does not exist")
            return
        }

        _ = legacyKeychain.remove(forKey: key)
        if keychain.remove(forKey: key) {
            call.resolve(["value": true])
        } else {
            call.reject("Remove failed")
        }
    }

    @objc func clear(_ call: CAPPluginCall) {
        let keys = keychain.allKeys()
        if keys.isEmpty {
            call.resolve(["value": true])
            return
        }

        for key in keys where legacyKeychain.hasValue(forKey: key) {
            if !legacyKeychain.remove(forKey: key) {
                call.reject("error")
                return
            }
        }

        if keychain.removeAll() {
            call.resolve(["value": true])
        } else {
            call.reject("error")
        }
    }

    @objc func getPlatform(_ call: CAPPluginCall) {
        call.resolve(["value": "ios"])
    }
}
