import { WebPlugin } from '@capacitor/core';
import { SecureStoragePluginPlugin } from './definitions';

export class SecureStoragePluginWeb extends WebPlugin implements SecureStoragePluginPlugin {
  PREFIX = 'cap_sec_';
  constructor() {
    super({
      name: 'SecureStoragePlugin',
      platforms: ['web'],
    });
  }

  get(options: { key: string }): Promise<{ value: string }> {
    return localStorage.getItem(this.addPrefix(options.key)) !== null
      ? Promise.resolve({
          value: atob(localStorage.getItem(this.addPrefix(options.key))),
        })
      : Promise.reject('Item with given key does not exist');
  }
  set(options: { key: string; value: string }): Promise<{ value: boolean }> {
    localStorage.setItem(this.addPrefix(options.key), btoa(options.value));
    return Promise.resolve({ value: true });
  }
  remove(options: { key: string }): Promise<{ value: boolean }> {
    localStorage.removeItem(this.addPrefix(options.key));
    return Promise.resolve({ value: true });
  }
  getPlatform(): Promise<{ value: string }> {
    return Promise.resolve({ value: 'web' });
  }

  private addPrefix = (key: string) => this.PREFIX + key;
}

const SecureStoragePlugin = new SecureStoragePluginWeb();

export { SecureStoragePlugin };
