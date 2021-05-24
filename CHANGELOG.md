## v0.6.2

- fix keys() serialization error on Android

## v0.6.1

- fix keys() serializable error on iOS

## v0.6.0

- migrate to capacitor 3.0
- for Capacitor 2.X.X install vesrion v0.5.1

  - `npm install capacitor-secure-storage-plugin@0.5.1`

- import plugin in web project in Capacitor v3 is `import { SecureStoragePlugin } from 'capacitor-secure-storage-plugin';` directly, instead of import of Plugins from capacitor/core

## v0.5.1

- fix Capacitor version to 2.X.X

## v0.5.0

- added keys() method - warning: returns just keys saved from this version up
- iOS: instead on standard keychain, wrapper service is used
- migration is not needed, plugin saves new values to wrapped keychain and get method uses standard keychain as a fallback

## v0.4.0

- rebased on Capacitor v2 plugin template
- added getPlatform() method

## v0.3.2

- update Capacitor dependencies

## v0.3.1

- fix long string handling
