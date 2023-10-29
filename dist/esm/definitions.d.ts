/**
 * allows to define how properties can be accessed on iOS
 */
export declare type Accessibility = 'afterFirstUnlock' | 'afterFirstUnlockThisDeviceOnly' | 'whenUnlocked' | 'whenUnlockedThisDeviceOnly' | 'always' | 'alwaysThisDeviceOnly' | 'whenPasscodeSetThisDeviceOnly';
export declare const accessibilityOptions: Accessibility[];
/**
 * allows to define how properties can be accessed on iOS
 */
export interface SetDataOptions {
    key: string;
    value: string;
    accessibility: Accessibility;
}
/**
 * The SecureStoragePlugin plugin interface
 */
export interface SecureStoragePluginPlugin {
    /**
     * gets the value for the given key
     *
     * @param options key to get value for
     * @returns value for the given key
     */
    get(options: {
        key: string;
    }): Promise<{
        value: string;
    }>;
    /**
     * gets the accessibility for the given key
     *
     * @param options key to get accessibility for
     * @returns accessibility for the given key
     */
    getAccessibility(options: {
        key: string;
    }): Promise<{
        value: string | undefined;
    }>;
    /**
     * sets the value for the given key
     *
     * @param options key and value to set
     * @returns true if the value was set successfully
     */
    set(options: SetDataOptions): Promise<{
        value: boolean;
    }>;
    /**
     * removes the value for the given key
     *
     * @param options key to remove value for
     * @returns true if the value was removed successfully
     */
    remove(options: {
        key: string;
    }): Promise<{
        value: boolean;
    }>;
    /**
     * clears all values
     *
     * @returns true if all values were removed successfully
     */
    clear(): Promise<{
        value: boolean;
    }>;
    /**
     * gets all keys
     *
     * @returns all keys
     */
    keys(): Promise<{
        value: string[];
    }>;
    /**
     * gets the platform
     *
     * @returns the platform
     */
    getPlatform(): Promise<{
        value: string;
    }>;
}
