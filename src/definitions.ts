export interface SecureStoragePluginPlugin {
  get(options: { serviceName?: string, key: string }): Promise<{ value: string }>;
  set(options: { serviceName?: string, key: string; value: string }): Promise<{ value: boolean }>;
  remove(options: { serviceName?: string, key: string }): Promise<{ value: boolean }>;
  clear(options: { serviceName?: string }): Promise<{ value: boolean }>;
  keys(options: { serviceName?: string }): Promise<{ value: string[] }>;
  getPlatform(): Promise<{ value: string }>;
}
