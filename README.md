# Capacitor Secure Storage Plugin

[![NPM Version](https://img.shields.io/npm/v/%40evva%2Fcapacitor-secure-storage-plugin)](https://www.npmjs.com/package/@evva/capacitor-secure-storage-plugin)
[![NPM Downloads](https://img.shields.io/npm/dy/%40evva%2Fcapacitor-secure-storage-plugin)](https://www.npmjs.com/package/@evva/capacitor-secure-storage-plugin)
![NPM Unpacked Size (with version)](https://img.shields.io/npm/unpacked-size/%40evva%2Fcapacitor-secure-storage-plugin/latest)
![GitHub last commit](https://img.shields.io/github/last-commit/evva-sfw/capacitor-secure-storage-plugin)
[![GitHub branch check runs](https://img.shields.io/github/check-runs/evva-sfw/capacitor-secure-storage-plugin/main)]([URL](https://github.com/evva-sfw/capacitor-secure-storage-plugin/actions))
[![EVVA License](https://img.shields.io/badge/license-EVVA_License-yellow.svg?color=fce500&logo=data:image/svg+xml;base64,PCEtLSBHZW5lcmF0ZWQgYnkgSWNvTW9vbi5pbyAtLT4KPHN2ZyB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjY0MCIgaGVpZ2h0PSIxMDI0IiB2aWV3Qm94PSIwIDAgNjQwIDEwMjQiPgo8ZyBpZD0iaWNvbW9vbi1pZ25vcmUiPgo8L2c+CjxwYXRoIGZpbGw9IiNmY2U1MDAiIGQ9Ik02MjIuNDIzIDUxMS40NDhsLTMzMS43NDYtNDY0LjU1MmgtMjg4LjE1N2wzMjkuODI1IDQ2NC41NTItMzI5LjgyNSA0NjYuNjY0aDI3NS42MTJ6Ij48L3BhdGg+Cjwvc3ZnPgo=)](LICENSE)

> [!IMPORTANT]
> This package was renamed please use the new package name! __@evva/capacitor-secure-storage-plugin__

Capacitor plugin for storing string values securly on iOS and Android.

## How to install

### Capacitor 6

```
npm install @evva/capacitor-secure-storage-plugin
```

### Capacitor 5

```
npm install @evva/capacitor-secure-storage-plugin@1.0.2
```

### Older versions

For version lower than 5 please refer to https://github.com/martinkasa/capacitor-secure-storage-plugin

## Compatibility

### iOS 15.0+
### Android API Level 29+

## Usage

```typescript
import { SecureStoragePlugin } from '@evva/capacitor-secure-storage-plugin';
```

## Methods

  ```ts

  get(options: { key: string }): Promise<{ value: string }>

  ```

  > **Note**
  > if item with specified key does not exist, throws an Error

  ---

  ```ts

  set(options: { key: string; value: string }): Promise<{ value: boolean }>

  ```

  > **Note**
  > return true in case of success otherwise throws an error

  ---

  ```ts

  remove(options: { key: string }): Promise<{ value: boolean }>

  ```

  > **Note**
  > return true in case of success otherwise throws an error

  ---

```ts
keys(): Promise<{ value: string[] }>
```

---

```ts

  clear(): Promise<{ value: boolean }>

  ```

  > **Note**
  > return true in case of success otherwise throws an error

  ---

  ```ts

  getPlatform(): Promise<{ value: string }>

  ```

  > **Note**
  > return returns which implementation is used - one of 'web', 'ios' or 'android'

## Example

```ts
const key = 'username';
const value = 'hellokitty2';

SecureStoragePlugin.set({ key, value })
  .then(success => console.log(success))
```

```ts
const key = 'username';
SecureStoragePlugin.get({ key })
  .then(value => {
    console.log(value);
  })
  .catch(error => {
    console.log('Item with specified key does not exist.');
  });
```

```ts
async getUsername(key: string) {
  return await SecureStoragePlugin.get({ key });
}
```

## Platform specific information

### iOS

This plugin uses the SimpleKeychain Swift library for iOS.

### Android

On Android it is implemented by AndroidKeyStore and SharedPreferences. Source: [Apriorit](https://www.apriorit.com/dev-blog/432-using-androidkeystore)

### Web

There is no secure storage in browser (not because it is not implemented by this plugin, but it does not exist at all). Values are stored in LocalStorage, but they are at least base64 encoded. Plugin adds 'cap*sec*' prefix to keys to avoid conflicts with other data stored in LocalStorage.
