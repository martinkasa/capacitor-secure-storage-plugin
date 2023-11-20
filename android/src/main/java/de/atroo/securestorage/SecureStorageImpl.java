package de.atroo.securestorage;

import android.content.Context;

public class SecureStorageImpl implements SecureStorageInterface {
    private SecureStorageInterface preferences = null;
    String preferencesName;
    String encryptedPreferencesName;

    SecureStorageImpl(Context context, String preferencesName, String encryptedPreferencesName) {
        this.preferencesName = preferencesName;
        this.encryptedPreferencesName = encryptedPreferencesName;
        init(context, "");
    }

    @Override
    public boolean init(Context context, String preferencesName) {
        boolean isInitialized = false;
        if (android.os.Build.VERSION.SDK_INT < 23) {
            preferences = new OldPreferencesImpl();
            isInitialized = preferences.init(context, this.preferencesName);
        } else {
            preferences = new EncryptedPreferencesImpl();
            isInitialized = preferences.init(context, this.encryptedPreferencesName);
            migrate(context);
        }

        if (!isInitialized && preferences instanceof EncryptedPreferencesImpl) {
            preferences = new OldPreferencesImpl();
            return preferences.init(context, this.preferencesName);
        }
        return isInitialized;
    }

    public void migrate(Context context) {
        if (preferences instanceof EncryptedPreferencesImpl) {
            OldPreferencesImpl oldPreferences = new OldPreferencesImpl();
            oldPreferences.init(context, this.preferencesName);

            String[] keys = oldPreferences.keys();
            for (String key : keys) {
                String data = oldPreferences.getData(key);
                preferences.setData(key, data);
                oldPreferences.remove(key);
            }
        }
    }

    @Override
    public void setData(String key, String value) {
        preferences.setData(key, value);
    }

    @Override
    public String getData(String key) {
        return preferences.getData(key);
    }

    @Override
    public String[] keys() {
        return preferences.keys();
    }

    @Override
    public void remove(String key) {
        preferences.remove(key);
    }

    @Override
    public void clear() {
        preferences.clear();
    }
}
