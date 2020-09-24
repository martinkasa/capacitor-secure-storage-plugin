import { WebPlugin } from '@capacitor/core';
export class SecureStoragePluginWeb extends WebPlugin {
    constructor() {
        super({
            name: 'SecureStoragePlugin',
            platforms: ['web'],
        });
        this.PREFIX = 'cap_sec_';
        this.addPrefix = (key) => this.PREFIX + key;
    }
    get(options) {
        return localStorage.getItem(this.addPrefix(options.key)) !== null
            ? Promise.resolve({
                value: decodeURIComponent(escape(atob(localStorage.getItem(this.addPrefix(options.key))))),
            })
            : Promise.reject('Item with given key does not exist');
    }
    set(options) {
        localStorage.setItem(this.addPrefix(options.key), btoa(unescape(encodeURIComponent(options.value))));
        return Promise.resolve({ value: true });
    }
    remove(options) {
        localStorage.removeItem(this.addPrefix(options.key));
        return Promise.resolve({ value: true });
    }
    clear() {
        for (var key in localStorage) {
            if (key.indexOf(this.PREFIX) === 0) {
                localStorage.removeItem(key);
            }
        }
        return Promise.resolve({ value: true });
    }
    getPlatform() {
        return Promise.resolve({ value: 'web' });
    }
}
const SecureStoragePlugin = new SecureStoragePluginWeb();
export { SecureStoragePlugin };
import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(SecureStoragePlugin);
//# sourceMappingURL=web.js.map