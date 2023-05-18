# capacitor-secure-storage-plugin

Capacitor plugin for storing string values securly on iOS and Android.

## How to install

For Capacitor v5

```bash
npm install capacitor-secure-storage-plugin
```

For Capacitor v4 - install with fixed version 0.8.1

```bash
npm install capacitor-secure-storage-plugin@0.8.1
```

For Capacitor v3 - install with fixed version 0.7.1

```bash
npm install capacitor-secure-storage-plugin@0.7.1
```

For Capacitor v2 - install with fixed version 0.5.1

```bash
npm install capacitor-secure-storage-plugin@0.5.1
```

## Usage

### For Capacitor v3 & v4

In a component where you want to use this plugin add to or modify imports:

```jsx
import { SecureStoragePlugin } from 'capacitor-secure-storage-plugin';
```

### For Capacitor v2

In a component where you want to use this plugin add to or modify imports:

```jsx
import 'capacitor-secure-storage-plugin';
import { Plugins } from '@capacitor/core';

const { SecureStoragePlugin } = Plugins;
```

First line is needed because of web part of the plugin (current behavior of Capacitor, this may change in future releases).

#### Capacitor V2 - Android

In Android with Capacitor v2 you have to register plugins manually in MainActivity class of your app.

[How to register plugins for Capacitor V2](https://capacitorjs.com/docs/v2/plugins/android#export-to-capacitor)

```ts
import com.whitestein.securestorage.SecureStoragePlugin;

...

public class MainActivity extends BridgeActivity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Initializes the Bridge
    this.init(savedInstanceState, new ArrayList<Class<? extends Plugin>>() {{
      // Additional plugins you've installed go here
      // Ex: add(TotallyAwesomePlugin.class);
      add(SecureStoragePlugin.class);
    }});
  }
}
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

SecureStoragePlugin.set({ key, value }).then(success => console.log(success));
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

This plugin uses SwiftKeychainWrapper under the hood for iOS.

> **Warning**
> Up to version v0.4.0 there was standard keychain used. Since v0.5.0 there is separate keychain wrapper, so keys() method returns only keys set in v0.5.0 or higher version.

### Android

On Android it is implemented by AndroidKeyStore and SharedPreferences. Source: [Apriorit](https://www.apriorit.com/dev-blog/432-using-androidkeystore)

> **Warning**
> For Android API < 18 values are stored as simple base64 encoded strings.

### Web

There is no secure storage in browser (not because it is not implemented by this plugin, but it does not exist at all). Values are stored in LocalStorage, but they are at least base64 encoded. Plugin adds 'cap*sec*' prefix to keys to avoid conflicts with other data stored in LocalStorage.
