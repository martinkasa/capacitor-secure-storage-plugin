import { registerPlugin } from "@capacitor/core";

import { SecureStoragePluginInterface } from "./definitions";

export const SecureStoragePlugin = registerPlugin<SecureStoragePluginInterface>("SecureStoragePlugin", {
  web: async () => await import("./web").then((m) => new m.SecureStoragePluginWeb()),
});

export * from "./definitions";

export interface SecureStorageInterface {
  SecureStoragePluginInterface: SecureStoragePluginInterface;
}
