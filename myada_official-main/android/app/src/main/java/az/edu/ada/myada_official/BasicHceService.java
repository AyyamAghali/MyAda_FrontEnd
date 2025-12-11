package az.edu.ada.myada_official;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.nfc.cardemulation.HostApduService;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

public class BasicHceService extends HostApduService {
    private static final String TAG = "HCE write";
    private static final int NOTIFICATION_ID = 1; // Define the notification ID

    // Define the UNKNOWN command response - missing constant that caused the error
    private static final byte[] UNKNOWN_CMD_SW = new byte[] { (byte) 0x6A, (byte) 0x82 };

    // Add standard success response code - This is what the legacy code returns
    private static final byte[] SELECT_OK_SW = new byte[] { (byte) 0x90, (byte) 0x00 };

    // Define the AID for exact matching with Arduino
    private static final byte[] SELECT_APPLICATION_APDU = new byte[] { 0x00, (byte) 0xA4, 0x04, 0x00, 0x07, (byte) 0xF0,
            0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x00 };

    public BasicHceService() {
        Log.i(TAG, "HCE constructor service started");
    }

    @SuppressLint("ForegroundServiceType")
    @Override
    public void onCreate() {
        try {
            super.onCreate();

            Log.i(TAG, "HCE Service Started");

            // Define Notification Channel for Android 8.0+ (which includes Android 9)
            String channelId = "HCE_Service_Channel";
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    NotificationChannel channel = new NotificationChannel(
                            channelId,
                            "HCE Service Notifications",
                            NotificationManager.IMPORTANCE_DEFAULT);
                    channel.setDescription("Notifications for HCE Service");

                    NotificationManager notificationManager = getSystemService(NotificationManager.class);
                    if (notificationManager != null) {
                        notificationManager.createNotificationChannel(channel);
                    }
                } catch (Exception e) {
                    Log.e(TAG, "Error creating notification channel: " + e.getMessage());
                }
            }

            // Build the Notification for Android 8.0+ (which includes Android 9)
            Notification notification = null;
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    notification = new Notification.Builder(this, channelId)
                            .setContentTitle("HCE Service Running")
                            .setContentText("Processing NFC Commands")
                            .setSmallIcon(android.R.drawable.ic_menu_info_details)
                            .build();
                } else {
                    // For older versions (pre-Oreo), although not needed for Android 9
                    notification = new Notification.Builder(this)
                            .setContentTitle("HCE Service Running")
                            .setContentText("Processing NFC Commands")
                            .setSmallIcon(android.R.drawable.ic_menu_info_details)
                            .build();
                }
            } catch (Exception e) {
                Log.e(TAG, "Error building notification: " + e.getMessage());
            }

            // Start as a Foreground Service - using simple method that works on Android 9
            if (notification != null) {
                try {
                    Log.i(TAG, "Starting service as foreground on Android " + Build.VERSION.SDK_INT);
                    startForeground(1, notification);
                    Log.i(TAG, "Successfully started foreground service");
                } catch (Exception e) {
                    Log.e(TAG, "Error starting foreground service: " + e.getMessage());
                }
            } else {
                Log.e(TAG, "Failed to create notification, cannot start foreground service");
            }
        } catch (Exception e) {
            Log.e(TAG, "Critical error in HCE service onCreate: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // Define the AID that you're expecting from the APDU command
    private static final byte[] SELECT_AID = new byte[] { 0x00, (byte) 0xA4, 0x04, 0x00, 0x07, (byte) 0xF0, 0x01, 0x02,
            0x03, 0x04, 0x05, 0x06, 0x00 };

    @Override
    public byte[] processCommandApdu(byte[] commandApdu, Bundle bundle) {
        // Check if we're allowed to process APDU commands
        SharedPreferences prefs = getSharedPreferences("flutter_shared_prefs", MODE_PRIVATE);
        boolean isLoggedIn = prefs.getBoolean("is_logged_in", false);

        Log.i(TAG, "=== NFC TRANSACTION ATTEMPT ===");
        Log.i(TAG, "Received APDU command: " + byteArrayToHexString(commandApdu));

        byte[] expectedSelectAidApdu = { 0x00, (byte) 0xA4, 0x04, 0x00, 0x07, (byte) 0xF0, 0x01, 0x02, 0x03, 0x04, 0x05,
                0x06, 0x00 };

        if (Arrays.equals(commandApdu, expectedSelectAidApdu)) {
            Log.d(TAG, "AID selected, responding...");

            // Get UID from SharedPreferences instead of using hardcoded value
            String loginUid = prefs.getString("uid", "Unknown");
            loginUid = loginUid.replace(" ", ""); // Remove spaces
            Log.d(TAG, "Responding with login UID: " + loginUid);
            return loginUid.getBytes(StandardCharsets.UTF_8);
        }

        // CRITICAL: Get the UID
        String uid = prefs.getString("uid", "");
        Log.i(TAG, "Original UID from SharedPreferences: '" + uid + "'");

        // Remove any spaces that might interfere with proper decoding
        uid = uid.replace(" ", "");
        Log.i(TAG, "Sending UID (cleaned): '" + uid + "'");

        // FOR ANY COMMAND WHATSOEVER, respond with the UID in UTF-8 format
        // This bypasses all command pattern matching logic
        Log.i(TAG, "⭐ BYPASSING COMMAND CHECKS - SENDING UID DIRECTLY ⭐");

        // Convert to UTF-8 bytes - the simplest encoding for the Arduino to decode
        byte[] response = uid.getBytes(StandardCharsets.UTF_8);

        Log.i(TAG, "SENDING UID AS BYTES: " + byteArrayToHexString(response));
        Log.i(TAG, "=== NFC TRANSACTION COMPLETE ===");

        return response;
    }

    @Override
    public void onDeactivated(int reason) {
        Log.i(TAG, "HCE service deactivated. Reason: " + reason);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        // Clear any notification
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(NOTIFICATION_ID);

        // Clear active status in shared preferences
        SharedPreferences prefs = getSharedPreferences("flutter_shared_prefs", MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putBoolean("is_hce_active", false);
        editor.apply();

        Log.i(TAG, "HCE Service destroyed and cleared data");
    }

    // Helper method to convert byte array to hex string
    public static String byteArrayToHexString(byte[] bytes) {
        final char[] hexArray = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
        char[] hexChars = new char[bytes.length * 2]; // Each byte has two hex characters (nibbles)
        int v;
        for (int j = 0; j < bytes.length; j++) {
            v = bytes[j] & 0xFF; // Cast bytes[j] to int, treating as unsigned value
            hexChars[j * 2] = hexArray[v >>> 4]; // Select hex character from upper nibble
            hexChars[j * 2 + 1] = hexArray[v & 0x0F]; // Select hex character from lower nibble
        }
        return new String(hexChars);
    }

    // Helper method to convert hex string to byte array
    private static byte[] hexStringToByteArray(String s) {
        if (s == null || s.length() == 0) {
            return new byte[] { 0x00 }; // Return a default value if string is empty
        }

        int len = s.length();
        byte[] data = new byte[len / 2];

        try {
            for (int i = 0; i < len; i += 2) {
                data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                        + Character.digit(s.charAt(i + 1), 16));
            }
        } catch (Exception e) {
            Log.e(TAG, "Error converting hex string to byte array: " + e.getMessage());
            // If there's an error in conversion (like odd length), return a default
            // response
            return new byte[] { (byte) 0x90, (byte) 0x00 };
        }

        return data;
    }
}