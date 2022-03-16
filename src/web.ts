import { WebPlugin } from '@capacitor/core';
import { SetDataOptions } from '.';
import { SecureStoragePluginPlugin } from './definitions';

export class SecureStoragePluginWeb extends WebPlugin implements SecureStoragePluginPlugin {
  PREFIX = 'cap_sec_';

  get(options: { key: string }): Promise<{ value: string }> {
    return localStorage.getItem(this.addPrefix(options.key)) !== null
      ? Promise.resolve({
          value: atob(localStorage.getItem(this.addPrefix(options.key))),
        })
      : Promise.reject('Item with given key does not exist');
  }
  set(options: SetDataOptions): Promise<{ value: boolean }> {
    localStorage.setItem(this.addPrefix(options.key), btoa(options.value));
    return Promise.resolve({ value: true });
  }
  remove(options: { key: string }): Promise<{ value: boolean }> {
    localStorage.removeItem(this.addPrefix(options.key));
    return Promise.resolve({ value: true });
  }
  clear(): Promise<{ value: boolean }> {
    for (const key in localStorage) {
      if (key.indexOf(this.PREFIX) === 0) {
        localStorage.removeItem(key);
      }
    }
    return Promise.resolve({ value: true });
  }
  keys(): Promise<{ value: string[] }> {
    const keys = Object.keys(localStorage).filter((k) => k.indexOf(this.PREFIX) === 0);
    return Promise.resolve({ value: keys });
  }

  getPlatform(): Promise<{ value: string }> {
    return Promise.resolve({ value: 'web' });
  }

  private addPrefix = (key: string) => this.PREFIX + key;
}

const SecureStoragePlugin = new SecureStoragePluginWeb();

export { SecureStoragePlugin };
