import { Component } from '@angular/core';
import { AlertController } from '@ionic/angular';
import { SecureStoragePlugin } from '@evva-sfw/capacitor-secure-storage-plugin';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {
  constructor(private alertController: AlertController) {}

  async showPlatform() {
    try {
      const result = await SecureStoragePlugin.getPlatform();
      await this.showResult(result);
    } catch (err) {
      this.showError(err);
    }
  }

  async get(key: string) {
    try {
      const result = await SecureStoragePlugin.get({ key });
      await this.showResult(result);
    } catch (err) {
      this.showError(err);
    }
  }

  async set(key: string, value: string) {
    try {
      const result = await SecureStoragePlugin.set({ key, value });
      await this.showResult(result);
    } catch (err) {
      this.showError(err);
    }
  }

  async showResult(message) {
    const a = await this.alertController.create({
      header: 'Result',
      message: JSON.stringify(message),
      buttons: ['OK'],
    });
    a.present();
  }

  async remove(key: string) {
    try {
      const result = await SecureStoragePlugin.remove({ key });
      await this.showResult(result);
    } catch (err) {
      this.showError(err);
    }
  }

  async keys() {
    try {
      const result = await SecureStoragePlugin.keys();
      await this.showResult(result);
    } catch (err) {
      this.showError(err);
    }
  }

  async clear() {
    try {
      const result = await SecureStoragePlugin.clear();
      await this.showResult(result);
    } catch (err) {
      this.showError(err);
    }
  }

  async showError(error) {
    const a = await this.alertController.create({
      header: 'Error',
      message: error,
      buttons: ['OK'],
    });
    a.present();
  }
}
