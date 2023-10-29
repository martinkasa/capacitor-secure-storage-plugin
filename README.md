# @atroo/capacitor-secure-storage-plugin

Securely store secrets such as usernames, passwords, tokens, certificates or other sensitive information (strings) on iOS & Android

## Install

```bash
npm install @atroo/capacitor-secure-storage-plugin
npx cap sync
```

## API

<docgen-index>

* [`get(...)`](#get)
* [`getAccessibility(...)`](#getaccessibility)
* [`set(...)`](#set)
* [`remove(...)`](#remove)
* [`clear()`](#clear)
* [`keys()`](#keys)
* [`getPlatform()`](#getplatform)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

The SecureStoragePlugin plugin interface

### get(...)

```typescript
get(options: { key: string; }) => Promise<{ value: string; }>
```

gets the value for the given key

| Param         | Type                          | Description          |
| ------------- | ----------------------------- | -------------------- |
| **`options`** | <code>{ key: string; }</code> | key to get value for |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### getAccessibility(...)

```typescript
getAccessibility(options: { key: string; }) => Promise<{ value: string | undefined; }>
```

gets the accessibility for the given key

| Param         | Type                          | Description                  |
| ------------- | ----------------------------- | ---------------------------- |
| **`options`** | <code>{ key: string; }</code> | key to get accessibility for |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### set(...)

```typescript
set(options: SetDataOptions) => Promise<{ value: boolean; }>
```

sets the value for the given key

| Param         | Type                                                      | Description          |
| ------------- | --------------------------------------------------------- | -------------------- |
| **`options`** | <code><a href="#setdataoptions">SetDataOptions</a></code> | key and value to set |

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### remove(...)

```typescript
remove(options: { key: string; }) => Promise<{ value: boolean; }>
```

removes the value for the given key

| Param         | Type                          | Description             |
| ------------- | ----------------------------- | ----------------------- |
| **`options`** | <code>{ key: string; }</code> | key to remove value for |

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### clear()

```typescript
clear() => Promise<{ value: boolean; }>
```

clears all values

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### keys()

```typescript
keys() => Promise<{ value: string[]; }>
```

gets all keys

**Returns:** <code>Promise&lt;{ value: string[]; }&gt;</code>

--------------------


### getPlatform()

```typescript
getPlatform() => Promise<{ value: string; }>
```

gets the platform

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


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

</docgen-api>
