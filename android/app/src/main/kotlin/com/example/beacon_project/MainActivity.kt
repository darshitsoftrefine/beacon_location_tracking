package com.example.beacon_project
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onPause() {
        super.onPause()

        //Start Background service to scan BLE devices

    }

    override fun onResume() {
        super.onResume()

        //Stop Background service, app is in foreground
    }

}
