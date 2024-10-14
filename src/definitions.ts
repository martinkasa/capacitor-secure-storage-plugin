export interface SecureStoragePluginInterface {
  get: (options: {
    key: string;
    accessibility?: string;
    group?: string;
    isSynchronizable?: boolean;
  }) => Promise<{ value: string }>;
  set: (options: {
    key: string;
    value: string;
    accessibility?: string;
    group?: string;
    isSynchronizable?: boolean;
  }) => Promise<{ value: boolean }>;
  remove: (options: {
    key: string;
    accessibility?: string;
    group?: string;
    isSynchronizable?: boolean;
  }) => Promise<{ value: boolean }>;
  clear: () => Promise<{ value: boolean }>;
  keys: (options: { accessibility?: string; group?: string }) => Promise<{ value: string[] }>;
  getPlatform: () => Promise<{ value: string }>;
}
