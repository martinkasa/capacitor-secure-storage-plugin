export interface SecureStoragePluginPlugin {
  get(options: { key: string }): Promise<{ value: string }>;
  set(options: { key: string; value: string }): Promise<{ value: boolean }>;
  remove(options: { key: string }): Promise<{ value: boolean }>;
  clear(): Promise<{ value: boolean }>;
  keys(): Promise<{ value: string[] }>;
  getPlatform(): Promise<{ value: string }>;
}
