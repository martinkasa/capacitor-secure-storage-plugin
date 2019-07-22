import { WebPlugin } from '@capacitor/core';
import { SecureStoragePluginPlugin } from './definitions';
export declare class SecureStoragePluginWeb extends WebPlugin implements SecureStoragePluginPlugin {
    constructor();
    get(options: {
        key: string;
    }): Promise<{
        value: string;
    }>;
    set(options: {
        key: string;
        value: string;
    }): Promise<{
        value: boolean;
    }>;
    remove(options: {
        key: string;
    }): Promise<{
        value: boolean;
    }>;
}
declare const SecureStoragePlugin: SecureStoragePluginWeb;
export { SecureStoragePlugin };
