import Capacitor
import Foundation
import SimpleKeychain

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(SecureStoragePlugin)
public class SecureStoragePlugin: CAPPlugin {

    @objc
    func set(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let value = call.getString("value") ?? ""
        let accessibility = self.getAccessibility(a: call.getValue("accessibility") as? String)

        let simpleKeychain = SimpleKeychain(service: "cap_sec", accessibility: accessibility)

        do {
            try simpleKeychain.set(value, forKey: key)
        } catch {
            call.reject("Error setting value for key: '\(key)'")
        }

        call.resolve(["value": value])
    }

    @objc
    func get(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let accessibility = self.getAccessibility(a: call.getValue("accessibility") as? String)

        let simpleKeychain = SimpleKeychain(service: "cap_sec", accessibility: accessibility)

        if let hasItem = try? simpleKeychain.hasItem(forKey: key), hasItem {
            let value = try? simpleKeychain.string(forKey: key)
            if let val = value, val != "" {
                call.resolve(["value": val])
            } else {
                call.reject("Error getting value for key: '\(key)'")
            }
        } else {
            call.reject("Error key doesn't exist: '\(key)'")
        }
    }

    @objc
    func keys(_ call: CAPPluginCall) {
        let accessibility = self.getAccessibility(a: call.getValue("accessibility") as? String)

        let simpleKeychain = SimpleKeychain(service: "cap_sec", accessibility: accessibility)

        if let keys = try? simpleKeychain.keys() {
            call.resolve([
                "value": Array(keys),
            ])
        } else {
            call.reject("Error loading keys")
        }
    }

    @objc
    func remove(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let accessibility = self.getAccessibility(a: call.getValue("accessibility") as? String)

        let simpleKeychain = SimpleKeychain(service: "cap_sec", accessibility: accessibility)

        if let hasItem = try? simpleKeychain.hasItem(forKey: key), hasItem {
            do {
                try simpleKeychain.deleteItem(forKey: key)
                call.resolve()
            } catch {
                call.reject("Error removing key: \(key)")
            }
        } else {
            call.reject("Error key doesn't exist: '\(key)'")
        }
    }

    @objc
    func clear(_ call: CAPPluginCall) {
        let accessibility = self.getAccessibility(a: call.getValue("accessibility") as? String)

        let simpleKeychain = SimpleKeychain(service: "cap_sec", accessibility: accessibility)

        do {
            try simpleKeychain.deleteAll()
            call.resolve()
        } catch {
            call.reject("Error removing all keys")
        }
    }

    @objc
    func getPlatform(_ call: CAPPluginCall) {
        call.resolve([
            "value": "ios",
        ])
    }

    // MARK: - Helper

    private func getAccessibility(a: String?) -> Accessibility {
        switch a {
        case "whenUnlocked":
            return Accessibility.whenUnlocked
        case "whenUnlockedThisDeviceOnly":
            return Accessibility.whenUnlockedThisDeviceOnly
        case "whenPasscodeSetThisDeviceOnly":
            return Accessibility.whenPasscodeSetThisDeviceOnly
        case "afterFirstUnlock":
            return Accessibility.afterFirstUnlock
        case "afterFirstUnlockThisDeviceOnly":
            return Accessibility.afterFirstUnlockThisDeviceOnly
        default:
            return Accessibility.afterFirstUnlockThisDeviceOnly
        }
    }
}
