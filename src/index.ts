import { registerPlugin } from '@capacitor/core';
import type { SecureStoragePlugin as SecureStoragePluginType } from './definitions';

const SecureStoragePlugin = registerPlugin<SecureStoragePluginType>('SecureStoragePlugin', {
  web: () => import('./web').then((m) => new m.SecureStoragePluginWeb()),
});

export * from './definitions';
export { SecureStoragePlugin };
