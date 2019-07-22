package com.whitestein.securestorage;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import java.nio.charset.Charset;

@NativePlugin()
public class SecureStoragePlugin extends Plugin {
    private PasswordStorageHelper passwordStorageHelper = new PasswordStorageHelper(getContext());

    @PluginMethod()
    public void set(PluginCall call) {
        String key = call.getString("key");
        String value = call.getString("value");

        try {
            this.passwordStorageHelper.setData(key, value.getBytes(Charset.forName("UTF-8")));
            JSObject ret = new JSObject();
            ret.put("value", true);
            call.success(ret);
        }
        catch ( Exception exception) {
            call.error("error", exception);
        }
    }

    @PluginMethod()
    public void get(PluginCall call) {
        String key = call.getString("key");

        try {
            String value = new String(this.passwordStorageHelper.getData(key), Charset.forName("UTF-8"));
            JSObject ret = new JSObject();
            ret.put("value", value);
            call.success(ret);
        }
        catch ( Exception exception) {
            call.error("error", exception);
        }
    }

    @PluginMethod()
    public void remove(PluginCall call) {
        String key = call.getString("key");

        try {
            this.passwordStorageHelper.remove(key);
            JSObject ret = new JSObject();
            ret.put("value", true);
            call.success(ret);
        }
        catch ( Exception exception) {
            call.error("error", exception);
        }
    }
}
