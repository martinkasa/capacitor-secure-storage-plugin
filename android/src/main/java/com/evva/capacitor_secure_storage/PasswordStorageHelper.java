package com.evva.capacitor_secure_storage;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.security.KeyChain;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyInfo;
import android.security.keystore.KeyProperties;
import android.os.Build;
import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKeys;
import android.util.Base64;
import android.util.Log;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.UnrecoverableEntryException;
import java.security.GeneralSecurityException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.security.spec.AlgorithmParameterSpec;
import java.security.spec.InvalidKeySpecException;
import java.util.Set;
import java.util.Map;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

public class PasswordStorageHelper {

  private static final String LOG_TAG =
    PasswordStorageHelper.class.getSimpleName();
  private static final String PREFERENCES_FILE = "cap_sec";

  private PasswordStorageImpl passwordStorage;

  public PasswordStorageHelper(Context context) {
    passwordStorage = new PasswordStorageHelper_SDK18();

    boolean isInitialized = false;

    try {
      isInitialized = passwordStorage.init(context);
    } catch (Exception ex) {
      Log.e(
        LOG_TAG,
        "PasswordStorage initialisation error:" + ex.getMessage(),
        ex
      );
    }

    // Caution: on certain API 18+ devices an exception can occur when initializing PasswordStorageHelper_SDK18().
    // In this case, we will use the second implementation of the helper:
    if (
      !isInitialized && passwordStorage instanceof PasswordStorageHelper_SDK18
    ) {
      passwordStorage = new PasswordStorageHelper_SDK16();
      passwordStorage.init(context);
    }
  }

  public void setData(String key, byte[] data) {
    passwordStorage.setData(key, data);
  }

  public byte[] getData(String key) {
    return passwordStorage.getData(key);
  }

  public String[] keys() {
    return passwordStorage.keys();
  }

  public void remove(String key) {
    passwordStorage.remove(key);
  }

  public void clear() {
    passwordStorage.clear();
  }

  private interface PasswordStorageImpl {
    boolean init(Context context);

    void setData(String key, byte[] data);

    byte[] getData(String key);

    String[] keys();

    void remove(String key);

    void clear();
  }

  private static class PasswordStorageHelper_SDK16
    implements PasswordStorageImpl {

    private SharedPreferences preferences;

    @Override
    public boolean init(Context context) {
      SharedPreferences oldPrefs = context.getSharedPreferences(PREFERENCES_FILE, Context.MODE_PRIVATE);

      if (isAndroidMOrHigher()) {
        try {
          String masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC);
          preferences = EncryptedSharedPreferences.create(
            PREFERENCES_FILE,
            masterKeyAlias,
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
          );

          if (needsMigration(oldPrefs)) {
            SharedPreferences.Editor editor = preferences.edit();
            Map<String, ?> entries = oldPrefs.getAll();
            for (Map.Entry<String, ?> entry : entries.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              if (value instanceof String) {
                editor.putString(key, (String) value);
              }
            }
            editor.apply();
            oldPrefs.edit().clear().apply();
          }
          return true;
        } catch (GeneralSecurityException | IOException e) {
          Log.e(LOG_TAG, "Failed to initialize encrypted shared preferences", e);
          return false;
        }
      } else {
        preferences = oldPrefs;
        return true;
      }
    }

    private boolean needsMigration(SharedPreferences oldPrefs) {
      return oldPrefs != null && oldPrefs.getAll().size() > 0;
    }

    private boolean isAndroidMOrHigher() {
      return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M;
    }

    @Override
    @SuppressLint("ApplySharedPref")
    public void setData(String key, byte[] data) {
      if (data == null) return;
      Editor editor = preferences.edit();
      editor.putString(key, Base64.encodeToString(data, Base64.DEFAULT));
      editor.commit();
    }

    @Override
    public byte[] getData(String key) {
      String res = preferences.getString(key, null);
      if (res == null) return null;
      return Base64.decode(res, Base64.DEFAULT);
    }

    @Override
    public String[] keys() {
      Set<String> keySet = preferences.getAll().keySet();
      return keySet.toArray(new String[0]);
    }

    @Override
    @SuppressLint("ApplySharedPref")
    public void remove(String key) {
      Editor editor = preferences.edit();
      editor.remove(key);
      editor.commit();
    }

    @Override
    @SuppressLint("ApplySharedPref")
    public void clear() {
      Editor editor = preferences.edit();
      editor.clear();
      editor.commit();
    }
  }

  private static class PasswordStorageHelper_SDK18
    implements PasswordStorageImpl {

    private static final String KEY_ALGORITHM_RSA = "RSA";

    private static final String KEYSTORE_PROVIDER_ANDROID_KEYSTORE =
      "AndroidKeyStore";
    private static final String RSA_ECB_PKCS1_PADDING = "RSA/ECB/PKCS1Padding";

    private SharedPreferences preferences;
    private String alias = null;

    @SuppressWarnings("deprecation")
    @SuppressLint({ "NewApi", "TrulyRandom" })
    @Override
    public boolean init(Context context) {

      SharedPreferences oldPrefs = context.getSharedPreferences(PREFERENCES_FILE, Context.MODE_PRIVATE);
      alias = context.getPackageName() + "_cap_sec";

      if (!isAndroidMOrHigher()){
        if (!isKeyStoreSupported()) {
          return false;
        }
        preferences = oldPrefs;
      }
      else {
        try {
          String masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC);
          preferences = EncryptedSharedPreferences.create(
            PREFERENCES_FILE,
            masterKeyAlias,
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
          );

          if (needsMigration(oldPrefs)) {
            if (!isKeyStoreSupported()) {
              return false;
            }
            SharedPreferences.Editor editor = preferences.edit();
            Map<String, ?> entries = oldPrefs.getAll();
            for (Map.Entry<String, ?> entry : entries.entrySet()) {
              String key = entry.getKey();
              String encryptedData = (String) entry.getValue();
              byte[] decryptedData = getData(key);
              if (decryptedData != null) {
                String decryptedString = new String(decryptedData, StandardCharsets.UTF_8);
                editor.putString(key, decryptedString);
              }
            }
            editor.apply();
            oldPrefs.edit().clear().apply();
          }
          return true;
        } catch (GeneralSecurityException | IOException e) {
          Log.e(LOG_TAG, "Failed to initialize encrypted shared preferences", e);
          return false;
        }
      }

      return true;
    }

    private boolean isAndroidMOrHigher() {
      return android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M;
    }

    private boolean needsMigration(SharedPreferences oldPrefs) {
      return oldPrefs != null && oldPrefs.getAll().size() > 0;
    }

    private boolean isKeyStoreSupported() {
      KeyStore ks;
      try {
        ks = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID_KEYSTORE);
        ks.load(null);

        PrivateKey privateKey = (PrivateKey) ks.getKey(alias, null);
        if (privateKey != null && ks.getCertificate(alias) != null) {
          PublicKey publicKey = ks.getCertificate(alias).getPublicKey();
          if (publicKey != null) {
            return true;
          }
        }

        KeyPairGenerator kpGenerator = KeyPairGenerator.getInstance(KEY_ALGORITHM_RSA, KEYSTORE_PROVIDER_ANDROID_KEYSTORE);
        KeyGenParameterSpec spec = new KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_DECRYPT)
          .setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512)
          .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_PKCS1)
          .build();
        kpGenerator.initialize(spec);
        kpGenerator.generateKeyPair();

        KeyFactory keyFactory = KeyFactory.getInstance(privateKey.getAlgorithm(), "AndroidKeyStore");
        KeyInfo keyInfo = keyFactory.getKeySpec(privateKey, KeyInfo.class);
        boolean isHardwareBacked = keyInfo.isInsideSecureHardware();
        Log.d(LOG_TAG, "Hardware-backed keystore supported: " + isHardwareBacked);

      } catch (Exception e) {
        Log.e(LOG_TAG, "init(): failed to initialize KeyStore", e);
        return false;
      }
      return true;
    }

    @Override
    @SuppressLint("ApplySharedPref")
    public void setData(String key, byte[] data) {

      if (isAndroidMOrHigher()) {
        try {
          String value = new String(data);  // Suponiendo que data es texto plano
          Editor editor = preferences.edit();
          editor.putString(key, value);
          editor.commit();
        } catch (Exception e) {
          Log.e(LOG_TAG, "setData(): failed to set data for key: " + key, e);
        }
      } else {
        try {
          KeyStore ks = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID_KEYSTORE);

          ks.load(null);
          if (ks.getCertificate(alias) == null) return;

          PublicKey publicKey = ks.getCertificate(alias).getPublicKey();

          if (publicKey == null) {
            Log.d(LOG_TAG, "Error: Public key was not found in Keystore");
            return;
          }

          String value = encrypt(publicKey, data);

          Editor editor = preferences.edit();
          editor.putString(key, value);
          editor.commit();
        } catch (
          NoSuchAlgorithmException
          | InvalidKeyException
          | NoSuchPaddingException
          | IllegalBlockSizeException
          | BadPaddingException
          | NoSuchProviderException
          | InvalidKeySpecException
          | KeyStoreException
          | CertificateException
          | IOException e
        ) {
          Log.e(LOG_TAG, "setData(): failed to set data for key: " + key);
        }
      }
    }

    @Override
    public byte[] getData(String key) {
      if (isAndroidMOrHigher()) {
        String data = preferences.getString(key, null);
        return data != null ? data.getBytes() : null;
      } else {
        try {
          KeyStore ks = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID_KEYSTORE);
          ks.load(null);
          PrivateKey privateKey = (PrivateKey) ks.getKey(alias, null);
          return decrypt(privateKey, preferences.getString(key, null));
        } catch (
          KeyStoreException
          | NoSuchAlgorithmException
          | CertificateException
          | IOException
          | UnrecoverableEntryException
          | InvalidKeyException
          | NoSuchPaddingException
          | IllegalBlockSizeException
          | BadPaddingException
          | NoSuchProviderException e
        ) {
          Log.e(LOG_TAG, "getData(): failed to get data for key: " + key);
        }
        return null;
      }
    }

    @Override
    public String[] keys() {
      Set<String> keySet = preferences.getAll().keySet();
      return keySet.toArray(new String[0]);
    }

    @Override
    @SuppressLint("ApplySharedPref")
    public void remove(String key) {
      Editor editor = preferences.edit();
      editor.remove(key);
      editor.commit();
    }

    @Override
    @SuppressLint("ApplySharedPref")
    public void clear() {
      Editor editor = preferences.edit();
      editor.clear();
      editor.commit();
    }

    private static final int KEY_LENGTH = 2048;

    @SuppressLint("TrulyRandom")
    private static String encrypt(PublicKey encryptionKey, byte[] data)
      throws NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchProviderException, InvalidKeySpecException {
      if (data.length <= KEY_LENGTH / 8 - 11) {
        Cipher cipher = Cipher.getInstance(RSA_ECB_PKCS1_PADDING);
        cipher.init(Cipher.ENCRYPT_MODE, encryptionKey);
        byte[] encrypted = cipher.doFinal(data);
        return Base64.encodeToString(encrypted, Base64.DEFAULT);
      } else {
        Cipher cipher = Cipher.getInstance(RSA_ECB_PKCS1_PADDING);
        cipher.init(Cipher.ENCRYPT_MODE, encryptionKey);
        int limit = KEY_LENGTH / 8 - 11;
        int position = 0;
        ByteArrayOutputStream byteArrayOutputStream =
          new ByteArrayOutputStream();
        while (position < data.length) {
          if (data.length - position < limit) limit = data.length - position;
          byte[] tmpData = cipher.doFinal(data, position, limit);
          try {
            byteArrayOutputStream.write(tmpData);
          } catch (IOException e) {
            Log.e(LOG_TAG, "encrypt(): failed to write data to output stream");
          }
          position += limit;
        }

        return Base64.encodeToString(
          byteArrayOutputStream.toByteArray(),
          Base64.DEFAULT
        );
      }
    }

    private static byte[] decrypt(
      PrivateKey decryptionKey,
      String encryptedData
    )
      throws NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, NoSuchProviderException {
      if (encryptedData == null) return null;
      byte[] encryptedBuffer = Base64.decode(encryptedData, Base64.DEFAULT);

      if (encryptedBuffer.length <= KEY_LENGTH / 8) {
        Cipher cipher = Cipher.getInstance(RSA_ECB_PKCS1_PADDING);
        cipher.init(Cipher.DECRYPT_MODE, decryptionKey);
        return cipher.doFinal(encryptedBuffer);
      } else {
        Cipher cipher = Cipher.getInstance(RSA_ECB_PKCS1_PADDING);
        cipher.init(Cipher.DECRYPT_MODE, decryptionKey);
        int limit = KEY_LENGTH / 8;
        int position = 0;
        ByteArrayOutputStream byteArrayOutputStream =
          new ByteArrayOutputStream();
        while (position < encryptedBuffer.length) {
          if (encryptedBuffer.length - position < limit) limit =
            encryptedBuffer.length - position;
          byte[] tmpData = cipher.doFinal(encryptedBuffer, position, limit);
          try {
            byteArrayOutputStream.write(tmpData);
          } catch (IOException e) {
            Log.e(LOG_TAG, "decrypt(): failed to write data to output stream");
          }
          position += limit;
        }

        return byteArrayOutputStream.toByteArray();
      }
    }
  }
}
