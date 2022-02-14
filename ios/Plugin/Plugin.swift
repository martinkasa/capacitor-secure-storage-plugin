import Foundation
import Capacitor

// TODO: learn how guard statements work again, they do not work with try/catch
// TODO: remove all throwing of errors, use guard and call.resolve

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(SecureStoragePlugin)
public class SecureStoragePlugin: CAPPlugin {
    
    @objc func set(_ call: CAPPluginCall) throws {
        let key = call.getString("key") ?? ""
        let value = call.getString("value") ?? ""
        
        // Create access control rules for new keychain item
        let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, // requires device to have passcode, becomes inaccessible if passcode removed
            .biometryCurrentSet, // requires biometric auth, is invalidated if the user's biometry changes (re-enrol faceID, remove/add fingers to TouchID)
            nil) // TODO: catch errors?
        
        // Create a query dict for executing the add to keychain
        // TODO: note what all of these args do
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue,
            kSecAttrAccessControl as String: accessControl,
            kSecValueData as String: value
        ]
        
        // Execute the query & catch errors
        let status = SecItemAdd(query as CFDictionary, nil)
        do {
            try guard status == errSecSuccess else { throw KeychainError(status: status) }
            call.resolve([
                "value": true
            ])
        } catch KeychainError {
            call.reject(KeychainError.status)
        }
    }
    
    @objc func get(_ call: CAPPluginCall) throws {
        let key = call.getString("key") ?? ""
        let prompt = call.getString("prompt") ?? ""
        
        // Create a query dict for fetching our keychain item, including biometric prompt
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecUseOperationPrompt as String: prompt,
            kSecReturnData as String: true
        ]
        
        // Execute query, assign result to pointer, catch errors
        let result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        // Extract string from result data, throw error if its not a string
        do {
            try guard status == errSecSuccess else { throw KeychainError(status: status) }
            try guard let secretData = result as? Data,
                let secret = String(data: secretData, encoding: String.Encoding.utf8)
                else { throw KeychainError(status: errSecInternalError )}
            call.resolve([
                "value": secret
            ])
        } catch KeychainError {
            call.reject(KeychainError.status)
        }
    }
    
    @objc func remove(_ call: CAPPluginCall) throws {
        let key = call.getString("key") ?? ""
        
        // Create a query dict for deleting our keychain item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Execute query, catch errors
        let status = SecItemDelete(query as CFDictionary)
        do {
            guard status == errSecSuccess else { throw KeychainError(status: status) }
            call.resolve([
                "value": true
            ])
        } catch KeychainError {
            call.reject(KeychainError.status)
        }
    }
    
    @objc func getPlatform(_ call: CAPPluginCall) {
        call.resolve([
            "value": "ios"
        ])
    }
}
