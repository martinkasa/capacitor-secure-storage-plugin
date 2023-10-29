var capacitorSecureStoragePlugin = (function (exports, core) {
    'use strict';

    const accessibilityOptions = [
        'afterFirstUnlock',
        'afterFirstUnlockThisDeviceOnly',
        'whenUnlocked',
        'whenUnlockedThisDeviceOnly',
        'always',
        'alwaysThisDeviceOnly',
        'whenPasscodeSetThisDeviceOnly'
    ];

    // import { registerPlugin } from '@capacitor/core';
    const SecureStoragePlugin$1 = core.registerPlugin('SecureStoragePlugin', {
        web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.SecureStoragePluginWeb()),
    });

    class SecureStoragePluginWeb extends core.WebPlugin {
        constructor() {
            super(...arguments);
            this.PREFIX = 'cap_sec_';
            this.addPrefix = (key) => this.PREFIX + key;
        }
        get(options) {
            const item = localStorage.getItem(this.addPrefix(options.key));
            if (item !== null) {
                return Promise.resolve({
                    value: atob(item),
                });
            }
            else {
                return Promise.reject('Item with given key does not exist');
            }
        }
        getAccessibility(_options) {
            // Always rejects on web
            return Promise.reject('Item with given key does not exist');
        }
        set(options) {
            localStorage.setItem(this.addPrefix(options.key), btoa(options.value));
            return Promise.resolve({ value: true });
        }
        remove(options) {
            localStorage.removeItem(this.addPrefix(options.key));
            return Promise.resolve({ value: true });
        }
        clear() {
            for (const key in localStorage) {
                if (key.indexOf(this.PREFIX) === 0) {
                    localStorage.removeItem(key);
                }
            }
            return Promise.resolve({ value: true });
        }
        keys() {
            const keys = Object.keys(localStorage).filter((k) => k.indexOf(this.PREFIX) === 0);
            return Promise.resolve({ value: keys });
        }
        getPlatform() {
            return Promise.resolve({ value: 'web' });
        }
    }
    const SecureStoragePlugin = new SecureStoragePluginWeb();

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        SecureStoragePluginWeb: SecureStoragePluginWeb,
        SecureStoragePlugin: SecureStoragePlugin
    });

    exports.SecureStoragePlugin = SecureStoragePlugin$1;
    exports.accessibilityOptions = accessibilityOptions;

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
