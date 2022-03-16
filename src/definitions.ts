

/**
 * allows to define how properties can be accessed on iOS
 */
type Accessibility = 'afterFirstUnlock' | 'afterFirstUnlockThisDeviceOnly' | 'whenUnlocked' | 'whenUnlockedThisDeviceOnly' | 'always' | 'alwaysThisDeviceOnly' | 'whenPasscodeSetThisDeviceOnly'

export interface SetDataOptions {
  key: string
  value: string
  accessibility: Accessibility
}

export interface SecureStoragePluginPlugin {
  /**
   * 
   * @since 1.1.0
   */
  get(options: { key: string }): Promise<{ value: string }>;
  set(options: SetDataOptions): Promise<{ value: boolean }>;
  remove(options: { key: string }): Promise<{ value: boolean }>;
  clear(): Promise<{ value: boolean }>;
  keys(): Promise<{ value: string[] }>;
  getPlatform(): Promise<{ value: string }>;
}
