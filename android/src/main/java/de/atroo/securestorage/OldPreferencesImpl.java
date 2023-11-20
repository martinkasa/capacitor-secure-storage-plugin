package de.atroo.securestorage;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.security.KeyChain;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyInfo;
import android.security.keystore.KeyProperties;
import android.util.Base64;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigInteger;
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
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.security.spec.AlgorithmParameterSpec;
import java.security.spec.InvalidKeySpecException;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Set;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.security.auth.x500.X500Principal;

public class OldPreferencesImpl implements SecureStorageInterface {
    private static final String LOG_TAG = OldPreferencesImpl.class.getSimpleName();
    private SecureStorageInterface preferences = null;

    @Override
    public boolean init(Context context, String preferencesName) {
        preferences = new PreferencesSDK18Impl();
        boolean isInitialized = false;

        try {
            isInitialized = preferences.init(context, preferencesName);
        } catch (Exception ex) {
            Log.e(LOG_TAG, "PasswordStorage initialisation error:" + ex.getMessage(), ex);
        }

        return isInitialized;
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

    private static class PreferencesSDK18Impl implements SecureStorageInterface {
        private static final String KEY_ALGORITHM_RSA = "RSA";

        private static final String KEYSTORE_PROVIDER_ANDROID_KEYSTORE = "AndroidKeyStore";
        private static final String RSA_ECB_PKCS1_PADDING = "RSA/ECB/PKCS1Padding";

        private SharedPreferences preferences;
        private String alias = null;

        @SuppressWarnings("deprecation")
        @SuppressLint({"NewApi", "TrulyRandom"})
        @Override
        public boolean init(Context context, String preferencesName) {
            preferences = context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE);
            alias = context.getPackageName() + "_" + preferencesName;

            KeyStore ks;

            try {
                ks = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID_KEYSTORE);

                //Use null to load Keystore with default parameters.
                ks.load(null);

                // Check if Private and Public already keys exists. If so we don't need to generate them again
                PrivateKey privateKey = (PrivateKey) ks.getKey(alias, null);
                if (privateKey != null && ks.getCertificate(alias) != null) {
                    PublicKey publicKey = ks.getCertificate(alias).getPublicKey();
                    if (publicKey != null) {
                        // All keys are available.
                        return true;
                    }
                }
            } catch (Exception ex) {
                return false;
            }

            // Create a start and end time, for the validity range of the key pair that's about to be
            // generated.
            Calendar start = new GregorianCalendar();
            Calendar end = new GregorianCalendar();
            end.add(Calendar.YEAR, 10);

            // Specify the parameters object which will be passed to KeyPairGenerator
            AlgorithmParameterSpec spec;
            if (android.os.Build.VERSION.SDK_INT < 23) {
                spec = new android.security.KeyPairGeneratorSpec.Builder(context)
                        // Alias - is a key for your KeyPair, to obtain it from Keystore in future.
                        .setAlias(alias)
                        // The subject used for the self-signed certificate of the generated pair
                        .setSubject(new X500Principal("CN=" + alias))
                        // The serial number used for the self-signed certificate of the generated pair.
                        .setSerialNumber(BigInteger.valueOf(1337))
                        // Date range of validity for the generated pair.
                        .setStartDate(start.getTime()).setEndDate(end.getTime())
                        .build();
            } else {
                spec = new KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_DECRYPT)
                        .setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512)
                        .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_PKCS1)
                        .build();
            }

            // Initialize a KeyPair generator using the the intended algorithm (in this example, RSA
            // and the KeyStore. This example uses the AndroidKeyStore.
            KeyPairGenerator kpGenerator;
            try {
                kpGenerator = KeyPairGenerator.getInstance(KEY_ALGORITHM_RSA, KEYSTORE_PROVIDER_ANDROID_KEYSTORE);
                kpGenerator.initialize(spec);
                // Generate private/public keys
                kpGenerator.generateKeyPair();
            } catch (NoSuchAlgorithmException | InvalidAlgorithmParameterException |
                     NoSuchProviderException e) {
                e.printStackTrace();
            }

            // Check if device support Hardware-backed keystore
            try {
                boolean isHardwareBackedKeystoreSupported;
                if (android.os.Build.VERSION.SDK_INT < 23) {
                    isHardwareBackedKeystoreSupported = KeyChain.isBoundKeyAlgorithm(KeyProperties.KEY_ALGORITHM_RSA);
                } else {
                    PrivateKey privateKey = (PrivateKey) ks.getKey(alias, null);
                    KeyChain.isBoundKeyAlgorithm(KeyProperties.KEY_ALGORITHM_RSA);
                    KeyFactory keyFactory = KeyFactory.getInstance(privateKey.getAlgorithm(), "AndroidKeyStore");
                    KeyInfo keyInfo = keyFactory.getKeySpec(privateKey, KeyInfo.class);
                    isHardwareBackedKeystoreSupported = keyInfo.isInsideSecureHardware();
                }
                Log.d(LOG_TAG, "Hardware-Backed Keystore Supported: " + isHardwareBackedKeystoreSupported);
            } catch (NoSuchAlgorithmException | UnrecoverableKeyException |
                     InvalidKeySpecException | NoSuchProviderException |
                     java.security.KeyStoreException e) {
                return false;
            }

            return true;
        }

        @Override
        public void setData(String key, String value) {
            KeyStore ks;
            try {
                ks = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID_KEYSTORE);

                ks.load(null);
                if (ks.getCertificate(alias) == null) return;

                PublicKey publicKey = ks.getCertificate(alias).getPublicKey();

                if (publicKey == null) {
                    Log.d(LOG_TAG, "Error: Public key was not found in Keystore");
                    return;
                }

                String encValue = encrypt(publicKey, value);

                SharedPreferences.Editor editor = preferences.edit();
                editor.putString(key, encValue);
                editor.commit();
            } catch (NoSuchAlgorithmException | InvalidKeyException | IllegalBlockSizeException |
                     BadPaddingException | NoSuchProviderException | InvalidKeySpecException |
                     IOException | CertificateException | NoSuchPaddingException e) {
                e.printStackTrace();
            } catch (java.security.KeyStoreException e) {
                throw new RuntimeException(e);
            }
        }

        @Override
        public String getData(String key) {
            KeyStore ks;
            try {
                ks = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID_KEYSTORE);
                ks.load(null);
                PrivateKey privateKey = (PrivateKey) ks.getKey(alias, null);
                return decrypt(privateKey, preferences.getString(key, null));
            } catch (NoSuchAlgorithmException | CertificateException | IOException |
                     UnrecoverableEntryException | InvalidKeyException | NoSuchPaddingException |
                     IllegalBlockSizeException | BadPaddingException | NoSuchProviderException |
                     KeyStoreException e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        public String[] keys() {
            Set<String> keySet = preferences.getAll().keySet();
            keySet.remove("__androidx_security_crypto_encrypted_prefs_key_keyset__"); // Exclude the reserved key
            keySet.remove("__androidx_security_crypto_encrypted_prefs_value_keyset__"); // Exclude the reserved key

            return keySet.toArray(new String[keySet.size()]);
        }

        @Override
        public void remove(String key) {
            SharedPreferences.Editor editor = preferences.edit();
            editor.remove(key);
            editor.commit();
        }

        @Override
        public void clear() {
            SharedPreferences.Editor editor = preferences.edit();
            editor.clear();
            editor.commit();
        }

        private static final int KEY_LENGTH = 2048;

        @SuppressLint("TrulyRandom")
        private static String encrypt(PublicKey encryptionKey, String value) throws NoSuchAlgorithmException,
                NoSuchPaddingException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException,
                NoSuchProviderException, InvalidKeySpecException {
            byte[] data = value.getBytes(StandardCharsets.UTF_8);
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
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                while (position < data.length) {
                    if (data.length - position < limit)
                        limit = data.length - position;
                    byte[] tmpData = cipher.doFinal(data, position, limit);
                    try {
                        byteArrayOutputStream.write(tmpData);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    position += limit;
                }

                return Base64.encodeToString(byteArrayOutputStream.toByteArray(), Base64.DEFAULT);
            }
        }

        private static String decrypt(PrivateKey decryptionKey, String encryptedData) throws NoSuchAlgorithmException,
                NoSuchPaddingException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException,
                NoSuchProviderException, IOException {
            if (encryptedData == null)
                return null;
            byte[] encryptedBuffer = Base64.decode(encryptedData, Base64.DEFAULT);

            if (encryptedBuffer.length <= KEY_LENGTH / 8) {
                Cipher cipher = Cipher.getInstance(RSA_ECB_PKCS1_PADDING);
                cipher.init(Cipher.DECRYPT_MODE, decryptionKey);
                byte[] decryptedBuffer = cipher.doFinal(encryptedBuffer);
                return new String(decryptedBuffer, StandardCharsets.UTF_8);
            } else {
                Cipher cipher = Cipher.getInstance(RSA_ECB_PKCS1_PADDING);
                cipher.init(Cipher.DECRYPT_MODE, decryptionKey);
                int limit = KEY_LENGTH / 8;
                int position = 0;
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                while (position < encryptedBuffer.length) {
                    if (encryptedBuffer.length - position < limit)
                        limit = encryptedBuffer.length - position;
                    byte[] tmpData = cipher.doFinal(encryptedBuffer, position, limit);
                    try {
                        byteArrayOutputStream.write(tmpData);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    position += limit;
                }

                byteArrayOutputStream.close();
                return new String(byteArrayOutputStream.toByteArray(), StandardCharsets.UTF_8);
            }
        }
    }

}
