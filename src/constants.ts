import { Accessibility } from './definitions';  // Adjust the import path as necessary

export const accessibilityOptions: Accessibility[] = [
  'afterFirstUnlock',
  'afterFirstUnlockThisDeviceOnly',
  'whenUnlocked',
  'whenUnlockedThisDeviceOnly',
  'always',
  'alwaysThisDeviceOnly',
  'whenPasscodeSetThisDeviceOnly'
];