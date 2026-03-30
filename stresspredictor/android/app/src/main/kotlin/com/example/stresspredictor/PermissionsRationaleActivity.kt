package com.example.stresspredictor // Match your app bundle

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class PermissionsRationaleActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Just finish the activity, or show a dialog. The health package handles the rest.
        finish()
    }
}
