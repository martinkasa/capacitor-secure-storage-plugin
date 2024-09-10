<p align="center">
  <h1 align="center">Capacitor Secure Storage Plugin</h1>
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/@evva-sfw/capacitor-secure-storage-plugin">
    <img alt="NPM Version" src="https://img.shields.io/npm/v/%40evva-sfw%2Fcapacitor-secure-storage-plugin"></a>
  <a href="https://www.npmjs.com/package/@evva-sfw/capacitor-secure-storage-plugin">
  <img alt="NPM Downloads" src="https://img.shields.io/npm/dy/%40evva-sfw%2Fcapacitor-secure-storage-plugin"></a>
  <img alt="GitHub package.json dynamic" src="https://img.shields.io/github/package-json/packageManager/evva-sfw/capacitor-secure-storage-plugin">
  <img alt="NPM Unpacked Size (with version)" src="https://img.shields.io/npm/unpacked-size/%40evva-sfw%2Fcapacitor-secure-storage-plugin/latest">
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/evva-sfw/capacitor-secure-storage-plugin">
  <a href="https://github.com/evva-sfw/capacitor-secure-storage-plugin/actions"><img alt="GitHub branch check runs" src="https://img.shields.io/github/check-runs/evva-sfw/capacitor-secure-storage-plugin/main"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-EVVA_License-yellow.svg?color=fce500&logo=data:image/svg+xml;base64,PCEtLSBHZW5lcmF0ZWQgYnkgSWNvTW9vbi5pbyAtLT4KPHN2ZyB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjY0MCIgaGVpZ2h0PSIxMDI0IiB2aWV3Qm94PSIwIDAgNjQwIDEwMjQiPgo8ZyBpZD0iaWNvbW9vbi1pZ25vcmUiPgo8L2c+CjxwYXRoIGZpbGw9IiNmY2U1MDAiIGQ9Ik02MjIuNDIzIDUxMS40NDhsLTMzMS43NDYtNDY0LjU1MmgtMjg4LjE1N2wzMjkuODI1IDQ2NC41NTItMzI5LjgyNSA0NjYuNjY0aDI3NS42MTJ6Ij48L3BhdGg+Cjwvc3ZnPgo=" alt="EVVA License"></a>

</p>

Capacitor plugin for storing string values securly on iOS and Android.

## How to install

### Capacitor 5

```
npm install @evva-sfw/capacitor-secure-storage-plugin
```

### Older versions

For version lower than 5 please refer to https://github.com/martinkasa/capacitor-secure-storage-plugin

## Compatibility

### iOS 15.0+
### Android API Level 29+

## Usage

```typescript
import { SecureStoragePlugin } from '@evva-sfw/capacitor-secure-storage-plugin';
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
