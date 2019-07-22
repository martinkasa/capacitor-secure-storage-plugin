import { WebPlugin } from '@capacitor/core';
export class SecureStoragePluginWeb extends WebPlugin {
    constructor() {
        super({
            name: 'SecureStoragePlugin',
            platforms: ['web']
        });
    }
    get(options) {
        return Promise.resolve({ value: localStorage.getItem(options.key) });
    }
    set(options) {
        localStorage.setItem(options.key, options.value);
        return Promise.resolve({ value: true });
    }
    remove(options) {
        localStorage.removeItem(options.key);
        return Promise.resolve({ value: true });
    }
}
const SecureStoragePlugin = new SecureStoragePluginWeb();
export { SecureStoragePlugin };
import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(SecureStoragePlugin);
//# sourceMappingURL=web.js.map