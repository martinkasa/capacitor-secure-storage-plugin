package de.atroo.securestorage;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.json.JSONException;

@CapacitorPlugin(name = "SecureStoragePlugin")
public class SecureStoragePlugin extends Plugin {
    private static final String PREFERENCE_FILE = "cap_sec";
    private static final String ENCRYPTED_PREFERENCE_FILE = "cap_sec_enc";
    private SecureStorageImpl secureStorageImpl;

    @Override
    public void load() {
        secureStorageImpl = new SecureStorageImpl(getContext(), PREFERENCE_FILE, ENCRYPTED_PREFERENCE_FILE);
    }

    @PluginMethod
    public void set(PluginCall call) {
        String key = call.getString("key");
        String value = call.getString("value");

        if (key == null || value == null) {
            call.reject("Must provide a key and a value");
            return;
        }

        secureStorageImpl.setData(key, value);
        call.resolve();
    }

    @PluginMethod
    public void get(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide a key");
            return;
        }

        String value = secureStorageImpl.getData(key);
        if (value != null) {
            JSObject ret = new JSObject();
            ret.put("value", value);
            call.resolve(ret);
        } else {
            call.reject("No value found for the key: " + key);
        }
    }

    @PluginMethod
    public void getAccessibility(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide a key");
            return;
        }
        // No accessibility check needed for Android
        JSObject ret = new JSObject();
        ret.put("value", "");
        call.resolve(ret);
    }

    @PluginMethod
    public void keys(PluginCall call) {
        String[] keys = secureStorageImpl.keys();
        JSObject ret = new JSObject();
        try {
            JSArray keysArr = new JSArray(keys);
            ret.put("value", keysArr);
            call.resolve(ret);
        } catch (JSONException e) {
            call.reject("Failed to get keys", e);
        }
    }

    @PluginMethod
    public void remove(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide a key");
            return;
        }
        secureStorageImpl.remove(key);
        call.resolve();
    }

    @PluginMethod
    public void clear(PluginCall call) {
        secureStorageImpl.clear();
        call.resolve();
    }

    @PluginMethod
    public void getPlatform(PluginCall call) {
        secureStorageImpl.clear();
        JSObject ret = new JSObject();
        ret.put("value", "android");
        call.resolve(ret);
    }
}
