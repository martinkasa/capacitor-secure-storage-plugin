# capacitor-secure-storage-plugin

Capacitor plugin for storing string values securly on iOS and Android.

## How to install

For Capacitor < 2.0.0
```
npm install capacitor-secure-storage-plugin@0.3.2
```

For Capacitor >= 2.0.0 (supported from 0.4.0)
```
npm install capacitor-secure-storage-plugin
```

## Usage

In a component where you want to use this plugin add to or modify imports:

```
import 'capacitor-secure-storage-plugin';
import { Plugins } from '@capacitor/core';

const { SecureStoragePlugin } = Plugins;
```

First line is needed because of web part of the plugin (current behavior of Capacitor, this may change in future releases).

### Android

In Android you have to register plugins manually in MainActivity class of your app.

https://capacitor.ionicframework.com/docs/plugins/android/#export-to-capacitor

```
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

- **get**(options: { key: string }): Promise<{ value: string }>
  - if item with specified key does not exist, throws an Error
  
* **keys**(): Promise<{ value: string[] }>
* **set**(options: { key: string; value: string }): Promise<{ value: boolean }>
* **remove**(options: { key: string }): Promise<{ value: boolean }>
* **clear**(): Promise<{ value: boolean }>
  - set, remove and clear return true in case of success and false in case of error

- **getPlatform**(): Promise<{ value: string }>
  - returns which implementation is used - one of 'web', 'ios' or 'android'

## Example

```
const key = 'username';
const value = 'hellokitty2';

SecureStoragePlugin.set({ key, value })
  .then(success => console.log(success))
```

```
const key = 'username';
SecureStoragePlugin.get({ key })
  .then(value => {
    console.log(value);
  })
  .catch(error => {
    console.log('Item with specified key does not exist.');
  });
```

```
async getUsername(key: string) {
  return await SecureStoragePlugin.get({ key });
}
```

## Platform specific information

### iOS

This plugin uses SwiftKeychainWrapper under the hood for iOS.

### Android

On Android it is implemented by AndroidKeyStore and SharedPreferences. Source: [Apriorit](https://www.apriorit.com/dev-blog/432-using-androidkeystore)

##### Warning

For Android API < 18 values are stored as simple base64 encoded strings.

### Web

There is no secure storage in browser (not because it is not implemented by this plugin, but it does not exist at all). Values are stored in LocalStorage, but they are at least base64 encoded. Plugin adds 'cap*sec*' prefix to keys to avoid conflicts with other data stored in LocalStorage.
