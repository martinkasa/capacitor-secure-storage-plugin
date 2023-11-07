//
//  SecureStoragePlugin.swift
//  SecureStoragePlugin
//
//  Created by Laszlo Blum on 2023. 10. 27.
//

import Foundation
import Capacitor

@objc(SecureStoragePlugin)
public class SecureStoragePlugin: CAPPlugin {
    private let implementation = SecureStoragePluginImpl()
    
    override public func load() {
        super.load()
        NSLog("SecureStoragePlugin is loaded")
        do {
            try implementation.recoverFromTmp()
            NSLog("SecureStoragePlugin, recovery done")
        } catch {
            NSLog("SecureStoragePlugin, failed to recover")
        }
    }
    
    @objc func set(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let value = call.getString("value") ?? ""
        let accessibility = call.getString("accessibility") ?? "afterFirstUnlock"
        
        do {
            try implementation.set(key: key, value: value, accessibilityKey: accessibility)
            call.resolve([
                "value": true
            ])
        } catch {
            call.reject("error")
        }
    }
        
    @objc func get(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        do {
            let value = try implementation.get(key: key)
            
            if value == nil {
                call.reject("Item with given key does not exist")
                return
            }
            
            call.resolve([
                "value": value ?? ""
            ])
        } catch {
            call.reject("error")
        }
    }
    
    @objc func getAccessibility(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        let value = implementation.getAccessibility(key: key)
        
        if value == nil {
            call.reject("Item with given key does not exist")
            return
        }
        call.resolve([
            "value": lowercaseFirstCharacter(of: value?.description ?? "")
        ])
    }
    
    @objc func keys(_ call: CAPPluginCall) {
        let keys = implementation.keys()
        call.resolve([
            "value": Array(keys)
        ])
    }
    
    @objc func remove(_ call: CAPPluginCall) {
        let key = call.getString("key") ?? ""
        do {
            try implementation.remove(key: key)
            call.resolve([
                "value": true
            ])
        }
        catch {
            call.reject("error")
        }
    }
    
    @objc func clear(_ call: CAPPluginCall) {
        do {
            try implementation.clear()
            call.resolve([
                "value": true
            ])
        }
        catch {
            call.reject("error")
        }
    }
    
    @objc func getPlatform(_ call: CAPPluginCall) {
        call.resolve([
            "value": "ios"
        ])
    }
}
