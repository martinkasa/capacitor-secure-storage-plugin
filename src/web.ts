import { WebPlugin } from '@capacitor/core';
import { SecureStoragePluginPlugin } from './definitions';

export class SecureStoragePluginWeb extends WebPlugin implements SecureStoragePluginPlugin {
  constructor() {
    super({
      name: 'SecureStoragePlugin',
      platforms: ['web']
    });
  }

  get(options: { key: string }): Promise<{ value: string }> {
    return Promise.resolve({ value: localStorage.getItem(options.key) });
  }
  set(options: { key: string; value: string }): Promise<void> {
    localStorage.setItem(options.key, options.value);
    return Promise.resolve();
  }
  remove(options: { key: string }): Promise<void> {
    localStorage.removeItem(options.key);
    return Promise.resolve();
  }
}

const SecureStoragePlugin = new SecureStoragePluginWeb();

export { SecureStoragePlugin };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(SecureStoragePlugin);
