# DOCS

## API

<docgen-index>

* [`get(...)`](#get)
* [`set(...)`](#set)
* [`remove(...)`](#remove)
* [`clear()`](#clear)
* [`keys()`](#keys)
* [`getPlatform()`](#getplatform)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

## Details

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### get(...)

```typescript
get(options: { key: string; }) => Promise<{ value: string; }>
```

| Param         | Type                          |
| ------------- | ----------------------------- |
| **`options`** | <code>{ key: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

**Since:** 1.1.0

--------------------


### set(...)

```typescript
set(options: SetDataOptions) => Promise<{ value: boolean; }>
```

| Param         | Type                                                      |
| ------------- | --------------------------------------------------------- |
| **`options`** | <code><a href="#setdataoptions">SetDataOptions</a></code> |

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### remove(...)

```typescript
remove(options: { key: string; }) => Promise<{ value: boolean; }>
```

| Param         | Type                          |
| ------------- | ----------------------------- |
| **`options`** | <code>{ key: string; }</code> |

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### clear()

```typescript
clear() => Promise<{ value: boolean; }>
```

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### keys()

```typescript
keys() => Promise<{ value: string[]; }>
```

**Returns:** <code>Promise&lt;{ value: string[]; }&gt;</code>

--------------------


### getPlatform()

```typescript
getPlatform() => Promise<{ value: string; }>
```

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### Interfaces


#### SetDataOptions

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