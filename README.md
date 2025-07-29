# @atroo/capacitor-secure-storage-plugin

Securely store secrets such as usernames, passwords, tokens, certificates or other sensitive information (strings) on iOS & Android

## Compatibility

Since v5 we follow the versioning of Capacitor, which means v5 of this plugin can be used with Capacitor 5, while v6 can be used with Capacitor 6.

## Install

```bash
npm install @atroo/capacitor-secure-storage-plugin
npx cap sync
```

## Features

### Android

This plugin uses EncryptedSharedPreferences to store sensitive information securely on any Android device. It will automigrate data from older versions after update.

### iOS

When using `set()` you can specify a different accessibility modifier of the keychain to control, when access to a key should be allowed. Providing a different accessibility modifier on consecutive calls of `set()` for the same key, will remove the old key and create it new under the hood to prevent keychain errors.

## Notes

### Android

#### AutoBackup

To stay secure you need to handle the Auto Backup rules in Android.
Please refer to [this document](https://developer.android.com/guide/topics/data/autobackup#IncludingFiles).

#### Java 21

The plugin requires Java 21 to run.
You can set it using the following options:

- changing the IDE settings.
- changing the JAVA_HOME environment variable.
- changing `org.gradle.java.home` in `gradle.properties`.

##### upgrading gralde

go to android run
`./gradlew --version`
and check the Android Gradle Plugin version in android/build.gradle.

Edit gradle/wrapper/gradle-wrapper.properties:
`distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-all.zip`

Then update the wrapper:

`./gradlew wrapper --gradle-version 8.7`

## API

<docgen-index>

- [`setStorageAdapter(...)`](#setstorageadapter)
- [`getStorageAdapter()`](#getstorageadapter)
- [`get(...)`](#get)
- [`getAccessibility(...)`](#getaccessibility)
- [`set(...)`](#set)
- [`remove(...)`](#remove)
- [`clear()`](#clear)
- [`keys()`](#keys)
- [`getPlatform()`](#getplatform)
- [Interfaces](#interfaces)
- [Type Aliases](#type-aliases)
- [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

The SecureStoragePlugin plugin interface

### setStorageAdapter(...)

```typescript
setStorageAdapter(options: { web: { adapter: WebStorageAdapter; }; }) => Promise<{ value: boolean; }>
```

gets the value for the given key

| Param         | Type                                                                                    | Description          |
| ------------- | --------------------------------------------------------------------------------------- | -------------------- |
| **`options`** | <code>{ web: { adapter: <a href="#webstorageadapter">WebStorageAdapter</a>; }; }</code> | key to get value for |

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

---

### getStorageAdapter()

```typescript
getStorageAdapter() => Promise<{ adapter: WebStorageAdapter; }>
```

gets the current storage adapter or null

**Returns:** <code>Promise&lt;{ adapter: <a href="#webstorageadapter">WebStorageAdapter</a>; }&gt;</code>

---

### get(...)

```typescript
get(options: { key: string; }) => Promise<{ value: string; }>
```

gets the value for the given key

| Param         | Type                          | Description          |
| ------------- | ----------------------------- | -------------------- |
| **`options`** | <code>{ key: string; }</code> | key to get value for |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

---

### getAccessibility(...)

```typescript
getAccessibility(options: { key: string; }) => Promise<{ value: string | undefined; }>
```

gets the accessibility for the given key

| Param         | Type                          | Description                  |
| ------------- | ----------------------------- | ---------------------------- |
| **`options`** | <code>{ key: string; }</code> | key to get accessibility for |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

---

### set(...)

```typescript
set(options: SetDataOptions) => Promise<{ value: boolean; }>
```

sets the value for the given key

| Param         | Type                                                      | Description          |
| ------------- | --------------------------------------------------------- | -------------------- |
| **`options`** | <code><a href="#setdataoptions">SetDataOptions</a></code> | key and value to set |

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

---

### remove(...)

```typescript
remove(options: { key: string; }) => Promise<{ value: boolean; }>
```

removes the value for the given key

| Param         | Type                          | Description             |
| ------------- | ----------------------------- | ----------------------- |
| **`options`** | <code>{ key: string; }</code> | key to remove value for |

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

---

### clear()

```typescript
clear() => Promise<{ value: boolean; }>
```

clears all values

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

---

### keys()

```typescript
keys() => Promise<{ value: string[]; }>
```

gets all keys

**Returns:** <code>Promise&lt;{ value: string[]; }&gt;</code>

---

### getPlatform()

```typescript
getPlatform() => Promise<{ value: string; }>
```

gets the platform

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

---

### Interfaces

#### SetDataOptions

allows to define how properties can be accessed on iOS

| Prop                | Type                                                    |
| ------------------- | ------------------------------------------------------- |
| **`key`**           | <code>string</code>                                     |
| **`value`**         | <code>string</code>                                     |
| **`accessibility`** | <code><a href="#accessibility">Accessibility</a></code> |

### Type Aliases

#### Accessibility

allows to define how properties can be accessed on iOS

<code>'afterFirstUnlock' | 'afterFirstUnlockThisDeviceOnly' | 'whenUnlocked' | 'whenUnlockedThisDeviceOnly' | 'always' | 'alwaysThisDeviceOnly' | 'whenPasscodeSetThisDeviceOnly'</code>

### Enums

#### WebStorageAdapter

| Members              | Value                         |
| -------------------- | ----------------------------- |
| **`LocalStorage`**   | <code>'LocalStorage'</code>   |
| **`SessionStorage`** | <code>'SessionStorage'</code> |
| **`SessionCookie`**  | <code>'SessionCookie'</code>  |

</docgen-api>
