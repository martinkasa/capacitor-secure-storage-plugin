package de.atroo.securestorage;

import static org.junit.Assert.*;

import android.content.Context;

import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Test;
import org.junit.runner.RunWith;


/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class SecureStorageInstrumentedTest {
    SecureStorageImpl secureStorageImpl;
    OldPreferencesImpl oldPreferencesImpl;
    Context context;
    private static String TEST_FILENAME_ENCRYPTED = "cap_enc_test";
    private static String TEST_FILENAME = "cap_test";

    void setUp() {
        context = ApplicationProvider.getApplicationContext();
        secureStorageImpl = new SecureStorageImpl(context, TEST_FILENAME, TEST_FILENAME_ENCRYPTED);
        secureStorageImpl.init(context, TEST_FILENAME_ENCRYPTED);
        secureStorageImpl.clear();

        oldPreferencesImpl = new OldPreferencesImpl();
        oldPreferencesImpl.init(context, TEST_FILENAME);
        oldPreferencesImpl.clear();
    }

    @Test
    public void clear() throws Exception {
        setUp();
        assertEquals(secureStorageImpl.keys().length, 0);
    }

    @Test
    public void migrationOldExist() throws Exception {
        setUp();
        oldPreferencesImpl.setData("key1", "value1");
        oldPreferencesImpl.setData("key2", "value2");
        oldPreferencesImpl.setData("key3", "value3");

        secureStorageImpl.migrate(context);

        assertEquals(secureStorageImpl.keys().length, 3);
        assertEquals(oldPreferencesImpl.keys().length, 0);

        assertEquals(secureStorageImpl.getData("key1"), "value1");
        assertEquals(secureStorageImpl.getData("key2"), "value2");
        assertEquals(secureStorageImpl.getData("key3"), "value3");
    }

    @Test
    public void migrationNoOld() throws Exception {
        setUp();
        secureStorageImpl.setData("key1", "value1");
        secureStorageImpl.setData("key2", "value2");
        secureStorageImpl.setData("key3", "value3");

        secureStorageImpl.migrate(context);

        assertEquals(secureStorageImpl.keys().length, 3);
        assertEquals(oldPreferencesImpl.keys().length, 0);
    }

    @Test
    public void migrationEmpty() throws Exception {
        setUp();
        secureStorageImpl.migrate(context);

        assertEquals(secureStorageImpl.keys().length, 0);
        assertEquals(oldPreferencesImpl.keys().length, 0);
    }

    @Test
    public void setData() throws Exception {
        setUp();
        secureStorageImpl.setData("key1", "value1");
        secureStorageImpl.setData("key2", "value2");
        secureStorageImpl.setData("key3", "value3");

        assertEquals(secureStorageImpl.keys().length, 3);
        assertEquals(secureStorageImpl.getData("key1"), "value1");
        assertEquals(secureStorageImpl.getData("key2"), "value2");
        assertEquals(secureStorageImpl.getData("key3"), "value3");
    }

    @Test
    public void keys() throws Exception {
        setUp();
        secureStorageImpl.setData("key1", "value1");
        secureStorageImpl.setData("key2", "value2");
        secureStorageImpl.setData("key3", "value3");

        String[] keys = secureStorageImpl.keys();
        assertEquals(keys.length, 3);
        assertEquals(keys[0], "key1");
        assertEquals(keys[1], "key2");
        assertEquals(keys[2], "key3");
    }

    @Test
    public void keysEmpty() throws Exception {
        setUp();
        String[] keys = secureStorageImpl.keys();
        assertEquals(keys.length, 0);
    }

    @Test
    public void remove() throws Exception {
        setUp();
        secureStorageImpl.setData("key1", "value1");
        secureStorageImpl.setData("key2", "value2");
        secureStorageImpl.setData("key3", "value3");

        secureStorageImpl.remove("key2");

        assertEquals(secureStorageImpl.keys().length, 2);
        assertEquals(secureStorageImpl.getData("key1"), "value1");
        assertEquals(secureStorageImpl.getData("key2"), null);
        assertEquals(secureStorageImpl.getData("key3"), "value3");
    }

    @Test
    public void removeEmpty() throws Exception {
        setUp();
        secureStorageImpl.remove("key2");
        assertEquals(secureStorageImpl.keys().length, 0);
    }

}
