import { Component } from '@angular/core';
import { SecureStoragePlugin } from '@evva-sfw/capacitor-secure-storage-plugin';
import { type AlertController } from '@ionic/angular';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {
  constructor(private readonly alertController: AlertController) {}

  async showPlatform(): Promise<void> {
    try {
      const result = await SecureStoragePlugin.getPlatform();
      await this.showResult(result);
    } catch (err) {
      await this.showError(err);
    }
  }

  async get(key: string): Promise<void> {
    try {
      const result = await SecureStoragePlugin.get({ key });
      await this.showResult(result);
    } catch (err) {
      await this.showError(err);
    }
  }

  async set(key: string, value: string): Promise<void> {
    try {
      const result = await SecureStoragePlugin.set({ key, value });
      await this.showResult(result);
    } catch (err) {
      await this.showError(err);
    }
  }

  async showResult(message): Promise<void> {
    const a = await this.alertController.create({
      header: 'Result',
      message: JSON.stringify(message),
      buttons: ['OK'],
    });
    await a.present();
  }

  async remove(key: string): Promise<void> {
    try {
      const result = await SecureStoragePlugin.remove({ key });
      await this.showResult(result);
    } catch (err) {
      await this.showError(err);
    }
  }

  async keys(): Promise<void> {
    try {
      const result = await SecureStoragePlugin.keys();
      await this.showResult(result);
    } catch (err) {
      await this.showError(err);
    }
  }

  async clear(): Promise<void> {
    try {
      const result = await SecureStoragePlugin.clear();
      await this.showResult(result);
    } catch (err) {
      await this.showError(err);
    }
  }

  async showError(error): Promise<void> {
    const a = await this.alertController.create({
      header: 'Error',
      message: error,
      buttons: ['OK'],
    });
    await a.present();
  }
}
