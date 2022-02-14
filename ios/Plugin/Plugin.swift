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
        
        // Create access control rules for new keychain item
        let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, // requires device to have passcode, becomes inaccessible if passcode removed
            .userPresence, // requires biometric auth, or fallback to passcode
            // TODO: What does biometryCurrentSet / .touchIdCurrentSet do here?
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
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
    
    @objc func get(_ call: CAPPluginCall) {
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
        guard status == errSecSuccess else { throw KeychainError(status: status) }

        // Extract string from result data, throw error if its not a string
        guard let secretData = result as? Data,
            let secret = String(data: secretData, encoding: String.Encoding.utf8)
            else { throw KeychainError(status: errSecInternalError )}
        
        return secret
    }
    
    @objc func remove(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        
        // Create a query dict for deleting our keychain item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        // Execute query, catch errors
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
    
    @objc func getPlatform(_ call: CAPPluginCall) {
        call.resolve([
            "value": "ios"
        ])
    }
}
