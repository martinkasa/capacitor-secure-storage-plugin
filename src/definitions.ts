export interface SecureStoragePluginPlugin {
    get(options: {
        key: string; accessibility?:
            | 'afterFirstUnlock'
            | 'afterFirstUnlockThisDeviceOnly'
            | 'whenUnlocked'
            | 'whenUnlockedThisDeviceOnly';
    }): Promise<{ value: string }>;
    set(options: {
        key: string; value: string; accessibility?:
            | 'afterFirstUnlock'
            | 'afterFirstUnlockThisDeviceOnly'
            | 'whenUnlocked'
            | 'whenUnlockedThisDeviceOnly';
    }): Promise<{ value: boolean }>;
    remove(options: { key: string }): Promise<{ value: boolean }>;
    clear(): Promise<{ value: boolean }>;
    keys(): Promise<{ value: string[] }>;
    getPlatform(): Promise<{ value: string }>;
}
