import { registerPlugin } from '@capacitor/core';
const SecureStoragePlugin = registerPlugin('SecureStoragePlugin', {
    web: () => import('./web').then((m) => new m.SecureStoragePluginWeb()),
});
export * from './definitions';
export { SecureStoragePlugin };
//# sourceMappingURL=index.js.map