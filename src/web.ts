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
    return Promise.resolve({ value: atob(localStorage.getItem(options.key)) });
  }
  set(options: { key: string; value: string }): Promise<{ value: boolean }> {
    localStorage.setItem(options.key, btoa(options.value));
    return Promise.resolve({ value: true });
  }
  remove(options: { key: string }): Promise<{ value: boolean }> {
    localStorage.removeItem(options.key);
    return Promise.resolve({ value: true });
  }
  clear(): Promise<{ value: boolean }> {
    localStorage.clear();
    return Promise.resolve({ value: true });
  }
}

const SecureStoragePlugin = new SecureStoragePluginWeb();

export { SecureStoragePlugin };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(SecureStoragePlugin);
