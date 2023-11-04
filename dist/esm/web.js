import { WebPlugin } from '@capacitor/core';
export class SecureStoragePluginWeb extends WebPlugin {
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
        return Promise.reject('not implemented on web');
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
export { SecureStoragePlugin };
//# sourceMappingURL=web.js.map