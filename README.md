# capacitor-secure-storage-plugin

Capacitor plugin for storing string values securly on iOS and Android.

## How to install

```
npm install capacitor-secure-storage-plugin
```

### iOS

This plugin uses SwiftKeychainWrapper under the hood for iOS.

### Android 

On Android it is implemented by AdroidKeyStore and SharedPreferences. Source: [Apriorit](https://www.apriorit.com/dev-blog/432-using-androidkeystore)

##### Warning 
For Android API < 18 values are stored as simple base64 encoded strings.

### Web

There is no secure storage in browser (not because it is not implemented by this plugin, but it does not exist at all). Values are stored in localStorage, but they are at least base64 encoded.
