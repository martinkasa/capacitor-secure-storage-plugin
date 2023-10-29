import { WebPlugin } from '@capacitor/core';
import { SetDataOptions } from '.';
import { Accessibility, SecureStoragePluginPlugin } from './definitions';
export declare class SecureStoragePluginWeb extends WebPlugin implements SecureStoragePluginPlugin {
    PREFIX: string;
    get(options: {
        key: string;
    }): Promise<{
        value: string;
    }>;
    getAccessibility(_options: {
        key: string;
    }): Promise<{
        value: Accessibility | undefined;
    }>;
    set(options: SetDataOptions): Promise<{
        value: boolean;
    }>;
    remove(options: {
        key: string;
    }): Promise<{
        value: boolean;
    }>;
    clear(): Promise<{
        value: boolean;
    }>;
    keys(): Promise<{
        value: string[];
    }>;
    getPlatform(): Promise<{
        value: string;
    }>;
    private addPrefix;
}
declare const SecureStoragePlugin: SecureStoragePluginWeb;
export { SecureStoragePlugin };
