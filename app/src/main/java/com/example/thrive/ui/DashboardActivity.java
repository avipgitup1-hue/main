package com.example.thrive.ui;
import android.content.Intent;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import com.example.thrive.data.AppDatabase;
import com.example.thrive.data.Expense;
import com.example.thrive.data.ExpenseDao;
import com.example.thrive.databinding.ActivityDashboardBinding;
import com.example.thrive.util.DateUtils;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Executors;
public class DashboardActivity extends AppCompatActivity {
    ActivityDashboardBinding b;
    ExpenseDao dao;
    RecentAdapter recentAdapter;
    public static final double MONTHLY_BUDGET = 2500.0;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        b = ActivityDashboardBinding.inflate(getLayoutInflater());
        setContentView(b.getRoot());
        dao = AppDatabase.getInstance(this).expenseDao();
        b.incomeTv.setText(format(3000));
        b.addExpenseBtn.setOnClickListener(v -> startActivity(new Intent(this, AddExpenseActivity.class)));
        b.spendingBtn.setOnClickListener(v -> startActivity(new Intent(this, SpendingActivity.class)));
        b.profileBtn.setOnClickListener(v -> startActivity(new Intent(this, ProfileActivity.class)));
        b.recentRv.setLayoutManager(new LinearLayoutManager(this));
        recentAdapter = new RecentAdapter();
        b.recentRv.setAdapter(recentAdapter);
    }
    @Override protected void onResume() {
        super.onResume();
        loadBudget();
        loadRecent();
    }
    private void loadBudget() {
        Executors.newSingleThreadExecutor().execute(() -> {
            Double sum = dao.sumExpenses(DateUtils.monthStartMillis(), DateUtils.monthEndMillis());
            final double spent = sum == null ? 0.0 : sum;
            runOnUiThread(() -> {
                b.expensesTv.setText(format(spent));
                b.spentTv.setText("Spent: " + format(spent));
                double left = Math.max(0, MONTHLY_BUDGET - spent);
                b.leftTv.setText("Left: " + format(left));
                int progress = (int) Math.min(100, Math.round((spent / MONTHLY_BUDGET) * 100.0));
                b.budgetProgress.setProgress(progress);
                b.savingsTv.setText(format(3000 - spent));
            });
        });
    }
    private void loadRecent() {
        Executors.newSingleThreadExecutor().execute(() -> {
            List<Expense> list = dao.getAllExpenses();
            List<Expense> recent = new ArrayList<>();
            for (int i=0;i<Math.min(5, list.size());i++) recent.add(list.get(i));
            runOnUiThread(() -> recentAdapter.setItems(recent));
        });
    }
    private String format(double v) { return NumberFormat.getCurrencyInstance(Locale.getDefault()).format(v); }
}
