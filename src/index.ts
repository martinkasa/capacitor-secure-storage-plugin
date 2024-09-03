import { registerPlugin } from '@capacitor/core';

import { type SecureStoragePluginInterface } from './definitions';

const SecureStoragePlugin = registerPlugin<SecureStoragePluginInterface>('SecureStoragePlugin', {
  web: async () => await import('./web').then((m) => new m.SecureStoragePluginWeb()),
});

export * from './definitions';
export { SecureStoragePlugin };
