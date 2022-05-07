import { WebPlugin } from '@capacitor/core';
import type { SecureStoragePluginPlugin } from './definitions';

export class SecureStoragePluginWeb
  extends WebPlugin
  implements SecureStoragePluginPlugin {
  PREFIX = 'cap_sec_';

  get(options: { key: string }): Promise<{ value: string }> {
    const value = localStorage.getItem(this.addPrefix(options.key));
    return value !== null
      ? Promise.resolve({
          value: atob(value),
        })
      : Promise.reject('Item with given key does not exist');
  }
  set(options: { key: string; value: string }): Promise<{ value: boolean }> {
    localStorage.setItem(this.addPrefix(options.key), btoa(options.value));
    return Promise.resolve({ value: true });
  }
  remove(options: { key: string }): Promise<{ value: boolean }> {
    if (localStorage.getItem(this.addPrefix(options.key))) {
      localStorage.removeItem(this.addPrefix(options.key));
      return Promise.resolve({ value: true });
    } else {
      return Promise.reject('Item with given key does not exist');
    }
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
    const keys = Object.keys(localStorage)
      .filter(k => k.indexOf(this.PREFIX) === 0)
      .map(this.removePrefix);
    return Promise.resolve({ value: keys });
  }

  getPlatform(): Promise<{ value: string }> {
    return Promise.resolve({ value: 'web' });
  }

  private addPrefix = (key: string) => this.PREFIX + key;
  private removePrefix = (key: string) => key.replace(this.PREFIX, '');
}
