package com.example.thrive.ui;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import com.example.thrive.data.AppDatabase;
import com.example.thrive.data.Expense;
import com.example.thrive.data.ExpenseDao;
import com.example.thrive.databinding.ActivityTransactionsBinding;
import java.util.List;
import java.util.concurrent.Executors;
public class TransactionsActivity extends AppCompatActivity {
    ActivityTransactionsBinding b;
    ExpenseDao dao;
    TransactionsAdapter adapter;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        b = ActivityTransactionsBinding.inflate(getLayoutInflater());
        setContentView(b.getRoot());
        dao = AppDatabase.getInstance(this).expenseDao();
        b.rv.setLayoutManager(new LinearLayoutManager(this));
        adapter = new TransactionsAdapter();
        b.rv.setAdapter(adapter);
    }
    @Override protected void onResume() {
        super.onResume();
        Executors.newSingleThreadExecutor().execute(() -> {
            List<Expense> list = dao.getAllExpenses();
            runOnUiThread(() -> adapter.setItems(list));
        });
    }
}
