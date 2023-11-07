import { WebPlugin } from '@capacitor/core';
import { SetDataOptions } from '.';
import { Accessibility, SecureStoragePlugin } from './definitions';

export class SecureStoragePluginWeb extends WebPlugin implements SecureStoragePlugin {
  PREFIX = 'cap_sec_';

  get(options: { key: string }): Promise<{ value: string }> {
    const item = localStorage.getItem(this.addPrefix(options.key));
    if (item !== null) {
      return Promise.resolve({
        value: atob(item),
      });
    } else {
      return Promise.reject('Item with given key does not exist');
    }
  }

  getAccessibility(_options: { key: string }): Promise<{ value: Accessibility|undefined }> {
    // Always rejects on web
    return Promise.reject('not implemented on web');
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
