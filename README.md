# @evva-sfw/capacitor-secure-storage-plugin

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
