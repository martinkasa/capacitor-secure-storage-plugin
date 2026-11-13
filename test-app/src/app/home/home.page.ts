import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AlertController, IonButton, IonContent, IonHeader, IonTitle, IonToolbar } from '@ionic/angular';
import { SecureStoragePlugin } from 'capacitor-secure-storage-plugin';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
  imports: [FormsModule, IonHeader, IonToolbar, IonTitle, IonContent, IonButton],
})
export class HomePage {
  private readonly alertController = inject(AlertController);

  readonly getKey = signal('');
  readonly setKey = signal('');
  readonly setValue = signal('');
  readonly removeKey = signal('');

  showPlatform() {
    return this.run(() => SecureStoragePlugin.getPlatform());
  }

  get() {
    return this.run(() => SecureStoragePlugin.get({ key: this.getKey() }));
  }

  set() {
    return this.run(() => SecureStoragePlugin.set({ key: this.setKey(), value: this.setValue() }));
  }

  remove() {
    return this.run(() => SecureStoragePlugin.remove({ key: this.removeKey() }));
  }

  keys() {
    return this.run(() => SecureStoragePlugin.keys());
  }

  clear() {
    return this.run(() => SecureStoragePlugin.clear());
  }

  private async run(action: () => Promise<unknown>) {
    try {
      await this.showAlert('Result', JSON.stringify(await action()));
    } catch (error) {
      await this.showAlert('Error', String(error));
    }
  }

  private async showAlert(header: string, message: string) {
    const alert = await this.alertController.create({ header, message, buttons: ['OK'] });
    await alert.present();
  }
}
