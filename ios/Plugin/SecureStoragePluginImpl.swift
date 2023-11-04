//
//  SecureStoragePluginImpl.swift
//  SecureStoragePluginImpl
//
//  Created by Laszlo Blum on 2023. 10. 27.
//

import Foundation
import KeychainAccess

public class SecureStoragePluginImpl: NSObject {
    let keychain = Keychain(service: "cap_sec")
    let keychainTmp = Keychain(service: "cap_sec_tmp")
    
    override init() {
        super.init()
    }
    
    public func set(key: String, value: String, accessibilityKey: String = "afterFirstUnlock") throws {
        let accessibility = keychainAccessibilityModeLookup[accessibilityKey] ?? defaultAccessibility
        let storedAccessibility = getAccessibility(key: key)
        let needReAdd = storedAccessibility != nil && accessibility != storedAccessibility
        
        if needReAdd {
            try copyToTmp(key: key, accessibility: accessibility)
            try remove(key: key)
        }
        
        try keychain
            .accessibility(accessibility)
            .set(value, key: key)
        
        if needReAdd {
            try removeFromTmp(key: key)
        }
    }
    
    func getAccessibility(key: String) -> Accessibility?  {
        do {
            if let item = try keychain.get(key, handler: { $0 }), let rawValue = item["pdmn"] {
                let accessibility = Accessibility(rawValue: rawValue as! String)
                if accessibility != nil {
                    return accessibility
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func hasKey(key: String) -> Bool {
        do {
            let keys = keys()
            return keys.contains(key)
        }
    }
    
    func copyToTmp(key: String, accessibility: Accessibility) throws {
        if let value = try keychain.get(key) {
            let tmpValue = TmpValues(key: key, value: value, accessibility: accessibility)
            let jsonData = try JSONEncoder().encode(tmpValue)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                try keychainTmp.set(jsonString, key: key)
            }
            return
        }
        
        throw Status.conversionError
    }
    
    func getTmp(key: String) throws -> TmpValues? {
        let tmpStr = try keychainTmp.get(key)
        if tmpStr == nil {
            return nil
        }

        if let data = tmpStr!.data(using: .utf8) {
            let decoder = JSONDecoder()
            let tmpValues = try decoder.decode(TmpValues.self, from: data)
            return tmpValues
        }
        return nil
    }
    
    func tmpKeys() -> [String] {
        let keys = keychainTmp.allKeys();
        return keys
    }
    
    func recoverFromTmp() throws {
        for key in tmpKeys() {
            if let item = try getTmp(key: key) {
                try remove(key: key)
                try set(key: key, value: item.value, accessibilityKey: getAccessibilityString(accessibility: item.accessibility))
                try removeFromTmp(key: key)
            }
        }
    }
    
    func removeFromTmp(key: String) throws {
        try keychainTmp.remove(key)
    }
    
    func get(key: String) throws -> String? {
        let value = try keychain.get(key)
        return value
    }
    
    func keys() -> [String] {
        let keys = keychain.allKeys();
        return keys
    }
    
    func remove(key: String) throws {
        try keychain.remove(key)
    }
    
    func clear() throws {
        try keychain.removeAll()
    }
    
    func clearTmp() throws {
        try keychainTmp.removeAll()
    }
}
