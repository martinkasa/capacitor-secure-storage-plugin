import { WebPlugin } from '@capacitor/core';

import type { SecureStoragePluginInterface } from './definitions';

export class SecureStoragePluginWeb extends WebPlugin implements SecureStoragePluginInterface {
  PREFIX = 'cap_sec_';

  async get(options: { key: string }): Promise<{ value: string }> {
    const value = localStorage.getItem(this.addPrefix(options.key));
    return value !== null
      ? {
          value: atob(value),
        }
      : await Promise.reject(new Error('Item with given key does not exist'));
  }

  async set(options: { key: string; value: string }): Promise<{ value: boolean }> {
    localStorage.setItem(this.addPrefix(options.key), btoa(options.value));
    return { value: true };
  }

  async remove(options: { key: string }): Promise<{ value: boolean }> {
    if (localStorage.getItem(this.addPrefix(options.key)) != null) {
      localStorage.removeItem(this.addPrefix(options.key));
      return { value: true };
    } else {
      throw new Error('Item with given key does not exist');
    }
  }

  async clear(): Promise<{ value: boolean }> {
    for (const key in localStorage) {
      if (key.indexOf(this.PREFIX) === 0) {
        localStorage.removeItem(key);
      }
    }
    return { value: true };
  }

  async keys(): Promise<{ value: string[] }> {
    const keys = Object.keys(localStorage)
      .filter((k) => k.indexOf(this.PREFIX) === 0)
      .map(this.removePrefix);
    return { value: keys };
  }

  async getPlatform(): Promise<{ value: string }> {
    return { value: 'web' };
  }

  private readonly addPrefix = (key: string): string => this.PREFIX + key;
  private readonly removePrefix = (key: string): string => key.replace(this.PREFIX, '');
}
