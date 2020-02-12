package com.whitestein.securestorage;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import java.nio.charset.Charset;

@NativePlugin()
public class SecureStoragePlugin extends Plugin {
    private PasswordStorageHelper passwordStorageHelper;

    @Override
    public void load() {
        super.load();
        this.passwordStorageHelper = new PasswordStorageHelper(getContext());
    }

    @PluginMethod()
    public void set(PluginCall call) {
        String key = call.getString("key");
        String value = call.getString("value");

        try {
            this.passwordStorageHelper.setData(key, value.getBytes(Charset.forName("UTF-8")));
            JSObject ret = new JSObject();
            ret.put("value", true);
            call.resolve(ret);
        }
        catch ( Exception exception) {
            call.reject("error", exception);
        }
    }

    @PluginMethod()
    public void get(PluginCall call) {
        String key = call.getString("key");

        try {
            byte[] buffer = this.passwordStorageHelper.getData(key);
            if(buffer != null && buffer.length > 0) {
                String value = new String(buffer, Charset.forName("UTF-8"));
                JSObject ret = new JSObject();
                ret.put("value", value);
                call.resolve(ret);
            }
            else {
                call.reject("Item with given key does not exist");
            }
        }
        catch ( Exception exception) {
            call.reject("error", exception);
        }
    }

    @PluginMethod()
    public void remove(PluginCall call) {
        String key = call.getString("key");

        try {
            this.passwordStorageHelper.remove(key);
            JSObject ret = new JSObject();
            ret.put("value", true);
            call.resolve(ret);
        }
        catch ( Exception exception) {
            call.reject("error", exception);
        }
    }

    @PluginMethod()
    public void clear(PluginCall call) {
        try {
            this.passwordStorageHelper.clear();
            JSObject ret = new JSObject();
            ret.put("value", true);
            call.resolve(ret);
        }
        catch ( Exception exception) {
            call.reject("error", exception);
        }
    }
}
