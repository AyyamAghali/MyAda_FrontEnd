package az.edu.ada.myada_official;

import android.content.ComponentName;
import android.content.Intent;
import android.content.SharedPreferences;
import android.nfc.NfcAdapter;
import android.nfc.cardemulation.CardEmulation;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "az.edu.ada.myada/apdu";
    private static final String TAG = "MyADA-MainActivity";

    private static final String PREFS_NAME = "flutter_shared_prefs";
    private Intent hceServiceIntent;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Initialize the HCE service intent
        hceServiceIntent = new Intent(this, BasicHceService.class);
    }

    @Override
    protected void onResume() {
        super.onResume();

        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        boolean isLoggedIn = prefs.getBoolean("is_logged_in", false);
        String uid = prefs.getString("uid", "");
        long lastPauseTime = prefs.getLong("last_pause_time", 0);
        long currentTime = System.currentTimeMillis();

        // If app was paused for more than 30 minutes, treat it as a real exit
        boolean wasLongPause = (currentTime - lastPauseTime) > (30 * 60 * 1000);

        // Auto start HCE service on resume if:
        // 1. User is logged in
        // 2. We have a valid UID
        // 3. Either this is a normal resume OR it was a long pause (app restarted)
        if (isLoggedIn && !uid.isEmpty() && (!wasLongPause || prefs.getBoolean("auto_restart_hce", true))) {
            Log.i(TAG, "Auto-starting HCE service on app resume");
            enableHceService();
        }
    }

    @Override
    protected void onStop() {
        // When app is stopped, always stop HCE regardless of user preference
        super.onStop();
        stopHceService();

        // Clear sensitive data
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putBoolean("is_hce_active", false);
        editor.apply();
    }

    @Override
    protected void onPause() {
        super.onPause();
        // Stop HCE service immediately when app goes to background
        stopHceService();

        // Save current timestamp when app is paused
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putLong("last_pause_time", System.currentTimeMillis());
        editor.apply();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("startHceService")) {
                                String uid = call.argument("uid");
                                if (uid != null && !uid.isEmpty()) {
                                    // Save UID to SharedPreferences
                                    SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
                                    SharedPreferences.Editor editor = prefs.edit();
                                    editor.putString("uid", uid);
                                    editor.apply();

                                    // Start HCE service
                                    boolean success = enableHceService();
                                    result.success(success);
                                } else {
                                    result.error("INVALID_UID", "UID cannot be null or empty", null);
                                }
                            } else if (call.method.equals("stopHceService")) {
                                // Stop HCE service when explicitly requested
                                boolean success = stopHceService();
                                result.success(success);
                            } else if (call.method.equals("userLoggedIn")) {
                                // Handle user login, save the status and UID
                                String uid = call.argument("uid");
                                if (uid != null && !uid.isEmpty()) {
                                    SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
                                    SharedPreferences.Editor editor = prefs.edit();
                                    editor.putString("uid", uid);
                                    editor.putBoolean("is_logged_in", true);
                                    editor.apply();

                                    // Auto-start HCE service on login
                                    boolean success = enableHceService();
                                    result.success(success);
                                } else {
                                    result.error("INVALID_UID", "UID cannot be null or empty", null);
                                }
                            } else if (call.method.equals("userLoggedOut")) {
                                // Handle user logout
                                SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
                                SharedPreferences.Editor editor = prefs.edit();
                                editor.putBoolean("is_logged_in", false);
                                editor.apply();

                                // Stop HCE service on logout
                                boolean success = stopHceService();
                                result.success(success);
                            } else if (call.method.equals("isHceSupported")) {
                                // This method should check if NFC hardware exists,
                                // not just if it's enabled (which is a different issue)
                                boolean isSupported = false;
                                try {
                                    NfcAdapter nfcAdapter = NfcAdapter.getDefaultAdapter(this);
                                    // If nfcAdapter is null, then the device definitely doesn't support NFC
                                    // If it's not null, the device has NFC hardware (even if it's disabled)
                                    isSupported = (nfcAdapter != null);

                                    Log.i(TAG, "NFC hardware support check: " + isSupported);
                                } catch (Exception e) {
                                    Log.e(TAG, "Error checking NFC support: " + e.getMessage());
                                    isSupported = false;
                                }
                                result.success(isSupported);
                            } else {
                                result.notImplemented();
                            }
                        });
    }

    private boolean enableHceService() {
        try {
            NfcAdapter nfcAdapter = NfcAdapter.getDefaultAdapter(this);
            if (nfcAdapter == null || !nfcAdapter.isEnabled()) {
                Log.e(TAG, "NFC is not available or disabled");
                return false;
            }

            // Set the HCE service as active in preferences
            SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("is_hce_active", true);
            editor.apply();

            // Start the HCE service explicitly
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(hceServiceIntent);
            } else {
                startService(hceServiceIntent);
            }

            // Try to set default service if possible
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                try {
                    CardEmulation cardEmulation = CardEmulation.getInstance(nfcAdapter);
                    ComponentName hceService = new ComponentName(this, BasicHceService.class);

                    // Try to set our service as the preferred service for our AID
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                        boolean setAsDefault = cardEmulation.setPreferredService(this, hceService);
                        Log.i(TAG, "Set as preferred service: " + setAsDefault);
                    }

                    // Just log if our service is not the default, but continue anyway
                    if (!cardEmulation.isDefaultServiceForCategory(hceService, CardEmulation.CATEGORY_OTHER)) {
                        Log.i(TAG, "HCE service is not the default for category 'other'");
                    }
                } catch (Exception e) {
                    // Just log and continue if this fails
                    Log.e(TAG, "Failed to check/set default HCE service: " + e.getMessage());
                }
            }

            Log.i(TAG, "HCE service started successfully");
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Error enabling HCE service: " + e.getMessage());
            return false;
        }
    }

    private boolean stopHceService() {
        try {
            Log.i(TAG, "Stopping HCE service");
            stopService(hceServiceIntent);
            // Also revoke any HCE parameters to prevent unauthorized access
            SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("is_hce_active", false);
            // We keep the UID in storage but set a flag that HCE is inactive
            editor.apply();
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Error stopping HCE service: " + e.getMessage());
            return false;
        }
    }
}
