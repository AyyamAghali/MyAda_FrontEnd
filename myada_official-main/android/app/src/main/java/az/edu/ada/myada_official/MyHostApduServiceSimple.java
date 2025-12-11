package az.edu.ada.myada_official;

import android.content.Context;
import android.content.SharedPreferences;
import android.nfc.cardemulation.HostApduService;
import android.os.Bundle;
import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

public class MyHostApduServiceSimple extends HostApduService {
    private static final String TAG = "MyADA-HCE-Simple";
    private static final int NOTIFICATION_ID = 2; // Different ID than the main service

    // ISO-DEP command HEADER for selecting an AID.
    // Format: [Class | Instruction | Parameter 1 | Parameter 2]
    private static final byte[] SELECT_APPLICATION_APDU = hexStringToByteArray("00A4040007F001020304050600");
    private static final String GET_DATA_APDU_HEADER = "00CA0000";
    private static final String PUT_DATA_APDU_HEADER = "00DA0000";

    // "OK" status word sent in response to SELECT AID command (0x9000)
    private static final byte[] SELECT_OK_SW = hexStringToByteArray("9000");
    // "UNKNOWN" status word sent in response to invalid APDU command (0x0000)
    private static final byte[] UNKNOWN_CMD_SW = hexStringToByteArray("0000");
    private static final byte[] SELECT_AID = new byte[] { (byte) 0xF0, (byte) 0x01, (byte) 0x02, (byte) 0x03,
            (byte) 0x04, (byte) 0x05, (byte) 0x06 };

    private byte[] fileContent01 = "MyADA App 1".getBytes(StandardCharsets.UTF_8);
    private byte[] fileContent02 = "MyADA App 2".getBytes(StandardCharsets.UTF_8);
    private byte[] fileContentUnknown = "MyADA App Unknown".getBytes(StandardCharsets.UTF_8);

    /**
     * Called if the connection to the NFC card is lost, in order to let the
     * application know the
     * cause for the disconnection (either a lost link, or another AID being
     * selected by the
     * reader).
     *
     * @param reason Either DEACTIVATION_LINK_LOSS or DEACTIVATION_DESELECTED
     */
    @Override
    public void onDeactivated(int reason) {
        Log.i(TAG, "HCE service deactivated. Reason: " + reason);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        // Clear active status in shared preferences
        SharedPreferences prefs = getSharedPreferences("flutter_shared_prefs", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putBoolean("is_hce_active", false);
        editor.apply();

        Log.i(TAG, "Simple HCE Service destroyed and cleared data");
    }

    /**
     * This method will be called when a command APDU has been received from a
     * remote device. A
     * response APDU can be provided directly by returning a byte-array in this
     * method. In general
     * response APDUs must be sent as quickly as possible, given the fact that the
     * user is likely
     * holding his device over an NFC reader when this method is called.
     *
     * @param commandApdu The APDU that received from the remote device
     * @param extras      A bundle containing extra data. May be null.
     * @return a byte-array containing the response APDU, or null if no response
     *         APDU can be sent
     *         at this point.
     */
    @Override
    public byte[] processCommandApdu(byte[] commandApdu, Bundle extras) {
        // Check if we're allowed to process APDU commands
        SharedPreferences prefs = getSharedPreferences("flutter_shared_prefs", Context.MODE_PRIVATE);
        boolean isLoggedIn = prefs.getBoolean("is_logged_in", false);
        boolean isHceActive = prefs.getBoolean("is_hce_active", false);

        // If not logged in or app explicitly marked HCE as inactive, return error
        if (!isLoggedIn || !isHceActive) {
            Log.w(TAG, "Rejecting APDU command - not logged in or HCE inactive");
            return UNKNOWN_CMD_SW;
        }

        // Get the UID from SharedPreferen  ces
        String uid = prefs.getString("uid", "");
        if (uid.isEmpty()) {
            Log.w(TAG, "UID not found in SharedPreferences");
            return UNKNOWN_CMD_SW;
        }

        // The following flow is based on Appendix E "Example of Mapping Version 2.0
        // Command Flow"
        // in the NFC Forum specification
        Log.i(TAG, "Received APDU: " + byteArrayToHexString(commandApdu));

        // First command: Application select (Section 5.5.2 in NFC Forum spec)
        if (Arrays.equals(SELECT_APPLICATION_APDU, commandApdu)) {
            Log.i(TAG, "This is: 01 SELECT_APPLICATION_APDU");
            // Return the UID directly for the SELECT command
            Log.d(TAG, "Responding with UID: " + uid);
            return uid.getBytes(StandardCharsets.UTF_8);

            // Second command: Check if the received APDU command matches the AID
        } else if (Arrays.equals(commandApdu, SELECT_AID)) {
            // If the AID matches, send the UID as response
            Log.i(TAG, "AID matched! Sending UID.");
            return uid.getBytes(StandardCharsets.UTF_8);
        } else if (arraysStartWith(commandApdu, hexStringToByteArray(GET_DATA_APDU_HEADER))) {
            Log.i(TAG, "This is: 02 GET_DATA_APDU");

            // For data requests, send UID information
            byte[] uidBytes = uid.getBytes(StandardCharsets.UTF_8);
            byte[] response = new byte[uidBytes.length + SELECT_OK_SW.length];
            System.arraycopy(uidBytes, 0, response, 0, uidBytes.length);
            System.arraycopy(SELECT_OK_SW, 0, response, uidBytes.length, SELECT_OK_SW.length);
            Log.i(TAG, "GET_DATA_APDU Our Response: " + byteArrayToHexString(response));
            return response;

            // No write operations allowed in secure mode
        } else if (arraysStartWith(commandApdu, hexStringToByteArray(PUT_DATA_APDU_HEADER))) {
            Log.i(TAG, "PUT_DATA_APDU rejected for security reasons");
            return UNKNOWN_CMD_SW;

            // We're doing something outside our scope
        } else {
            Log.w(TAG, "processCommandApdu() | Unknown command received");
        }
        return UNKNOWN_CMD_SW;
    }

    boolean arraysStartWith(byte[] completeArray, byte[] compareArray) {
        int n = compareArray.length;
        return ByteBuffer.wrap(completeArray, 0, n).equals(ByteBuffer.wrap(compareArray, 0, n));
    }

    /**
     * Utility method to convert a byte array to a hexadecimal string.
     *
     * @param bytes Bytes to convert
     * @return String, containing hexadecimal representation.
     */
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

    /**
     * Utility method to convert a hexadecimal string to a byte string.
     *
     * <p>
     * Behavior with input strings containing non-hexadecimal characters is
     * undefined.
     *
     * @param s String containing hexadecimal characters to convert
     * @return Byte array generated from input
     * @throws IllegalArgumentException if input length is incorrect
     */
    public static byte[] hexStringToByteArray(String s) throws IllegalArgumentException {
        int len = s.length();
        if (len % 2 == 1) {
            throw new IllegalArgumentException("Hex string must have even number of characters");
        }
        byte[] data = new byte[len / 2]; // Allocate 1 byte per 2 hex characters
        for (int i = 0; i < len; i += 2) {
            // Convert each character into a integer (base-16), then bit-shift into place
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i + 1), 16));
        }
        return data;
    }
}