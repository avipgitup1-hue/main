package com.example.thrive.ui;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import com.example.thrive.databinding.ActivityProfileBinding;
public class ProfileActivity extends AppCompatActivity {
    ActivityProfileBinding b;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        b = ActivityProfileBinding.inflate(getLayoutInflater());
        setContentView(b.getRoot());
    }
}
