declare module '@capacitor/core' {
    interface PluginRegistry {
        SecureStoragePlugin: SecureStoragePluginPlugin;
    }
}
export interface SecureStoragePluginPlugin {
    get(options: {
        key: string;
    }): Promise<{
        value: string;
    }>;
    set(options: {
        key: string;
        value: string;
    }): Promise<void>;
    remove(options: {
        key: string;
    }): Promise<void>;
}
