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
    // `var` so tests can point the plugin at a test-only keychain service.
    var keychain = Keychain(service: "cap_sec")

    @objc func set(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let value = call.getString("value") ?? ""
        run(call) {
            try keychain.set(value, forKey: key)
            call.resolve(["value": true])
        }
    }

    @objc func get(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        run(call) {
            if let value = try keychain.string(forKey: key) {
                call.resolve(["value": value])
            } else {
                call.reject(Self.notFoundMessage)
            }
        }
    }

    @objc func keys(_ call: CAPPluginCall) {
        run(call) {
            call.resolve(["value": try keychain.allKeys()])
        }
    }

    @objc func remove(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        run(call) {
            if try keychain.remove(forKey: key) {
                call.resolve(["value": true])
            } else {
                call.reject(Self.notFoundMessage)
            }
        }
    }

    @objc func clear(_ call: CAPPluginCall) {
        run(call) {
            try keychain.removeAll()
            call.resolve(["value": true])
        }
    }

    @objc func getPlatform(_ call: CAPPluginCall) {
        call.resolve(["value": "ios"])
    }

    static let notFoundMessage = "Item with given key does not exist"

    /// Rejects with the keychain's message and OSStatus as code, so JS can tell
    /// e.g. a locked device (-25308) from a missing key.
    private func run(_ call: CAPPluginCall, _ body: () throws -> Void) {
        do {
            try body()
        } catch let error as KeychainError {
            call.reject(error.message, String(error.status), error)
        } catch {
            call.reject(error.localizedDescription, nil, error)
        }
    }
}
