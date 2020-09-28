package com.whitestein.securestorage;

import android.content.Context;

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

    public void loadTextContext(Context context) {
        this.passwordStorageHelper = new PasswordStorageHelper(context);
    }

    @PluginMethod()
    public void set(PluginCall call) {
        String key = call.getString("key");
        String value = call.getString("value");
        try {
            call.resolve(this._set(key,value));
        } catch (Exception exception) {
            call.reject(exception.getMessage(), exception);
        }
    }

    @PluginMethod()
    public void get(PluginCall call) {
        String key = call.getString("key");
        try {
          call.resolve(this._get(key));
        } catch (Exception exception) {
            call.reject(exception.getMessage(), exception);
        }
    }

    @PluginMethod()
    public void remove(PluginCall call) {
        String key = call.getString("key");
        try {
            call.resolve(this._remove(key));
        } catch (Exception exception) {
            call.reject(exception.getMessage(), exception);
        }
    }

    @PluginMethod()
    public void clear(PluginCall call) {
        try {
            call.resolve(this._clear());
        } catch (Exception exception) {
            call.reject(exception.getMessage(), exception);
        }
    }

    @PluginMethod()
    public void getPlatform(PluginCall call) {
        call.resolve(this._getPlatform());
    }

    public JSObject _set(String key, String value) {
        this.passwordStorageHelper.setData(key, value.getBytes(Charset.forName("UTF-8")));
        JSObject ret = new JSObject();
        ret.put("value", true);
        return ret;
    }

    public JSObject _get(String key) throws Exception {
        byte[] buffer = this.passwordStorageHelper.getData(key);
        JSObject ret = new JSObject();
        if (buffer != null && buffer.length > 0) {
            String value = new String(buffer, Charset.forName("UTF-8"));
            ret.put("value", value);
        } else {
            ret.put("value", null);
        }
        return ret;
    }

    public JSObject _remove(String key) {
        this.passwordStorageHelper.remove(key);
        JSObject ret = new JSObject();
        ret.put("value", true);
        return ret;
    }

    public JSObject _clear() {
        this.passwordStorageHelper.clear();
        JSObject ret = new JSObject();
        ret.put("value", true);
        return ret;
    }

    public JSObject _getPlatform() {
        JSObject ret = new JSObject();
        ret.put("value", "android");
        return ret;
    }

}
