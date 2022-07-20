# capacitor-secure-storage-plugin

Capacitor plugin for storing string values securly on iOS and Android.

This plugin only supports Capacitor 3.

## Why a fork?
The original plugin is not flexible enough for our purposes and the repo seems to be abandoned. Our goal for this fork is to make it as flexible as possible to configure the secure storage without assumptions.


## How to install

```
npm install @atroo/capacitor-secure-storage-plugin
```

## Usage

In a component where you want to use this plugin add to or modify imports:

```
import { SecureStoragePlugin } from '@atroo/capacitor-secure-storage-plugin';
```
## Example

Write data
```
const key = 'username';
const value = 'hellokitty2';

const storeData = async () => {
  const success = await SecureStoragePlugin.set({ key, value })
  console.log(success)
}

```

Read data
```
async getUsername(key: string) {
  return await SecureStoragePlugin.get({ key });
}
```

## API

Full API docs can be found [here](./DOCS.md)

## Platform specific information

### iOS

This plugin uses SwiftKeychainWrapper under the hood for iOS.

##### Warning

Up to version v0.4.0 there was standard keychain used. Since v0.5.0 there is separate keychain wrapper, so keys() method returns only keys set in v0.5.0 or higher version.

### Android

On Android it is implemented by AndroidKeyStore and SharedPreferences. Source: [Apriorit](https://www.apriorit.com/dev-blog/432-using-androidkeystore)

##### Warning

For Android API < 18 values are stored as simple base64 encoded strings.

### Web

There is no secure storage in browser (not because it is not implemented by this plugin, but it does not exist at all). Values are stored in LocalStorage, but they are at least base64 encoded. Plugin adds 'cap*sec*' prefix to keys to avoid conflicts with other data stored in LocalStorage.
