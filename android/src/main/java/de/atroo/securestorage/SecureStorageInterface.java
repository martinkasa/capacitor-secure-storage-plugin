package de.atroo.securestorage;

import android.content.Context;

public interface SecureStorageInterface {
    boolean init(Context context, String preferencesName);

    void setData(String key, String value);

    String getData(String key);

    String[] keys();

    void remove(String key);

    void clear();
}
