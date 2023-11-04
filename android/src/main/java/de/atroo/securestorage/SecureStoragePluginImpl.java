package de.atroo.securestorage;

import android.util.Log;

public class SecureStoragePluginImpl {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}
