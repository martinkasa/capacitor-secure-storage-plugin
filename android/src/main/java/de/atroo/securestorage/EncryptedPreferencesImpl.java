package de.atroo.securestorage;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;

import androidx.annotation.RequiresApi;
import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKeys;

import java.util.Map;
import java.util.Set;

@RequiresApi(api = Build.VERSION_CODES.M)
public class EncryptedPreferencesImpl implements SecureStorageInterface {
    private static final String TAG = "EncryptedPrefsImpl";
    private SharedPreferences sharedPreferences;

    @Override
    public boolean init(Context context, String preferencesName) {
        try {
            String masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC);

            sharedPreferences = EncryptedSharedPreferences.create(
                    preferencesName,
                    masterKeyAlias,
                    context,
                    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize EncryptedSharedPreferences", e);
        }

        return true;
    }

    @Override
    public void setData(String key, String value) {
        sharedPreferences.edit().putString(key, value).commit();
    }

    @Override
    public String getData(String key) {
        String encodedData = sharedPreferences.getString(key, null);
        return encodedData;
    }

    @Override
    public String[] keys() {
        Map<String, ?> allEntries = sharedPreferences.getAll();
        Set<String> keySet = allEntries.keySet();
        String[] keys = keySet.toArray(new String[0]);
        return keys;
    }

    @Override
    public void remove(String key) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.remove(key);
        editor.commit();
    }

    @Override
    public void clear() {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.commit();
    }
}
