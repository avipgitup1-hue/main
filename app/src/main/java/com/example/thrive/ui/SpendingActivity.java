package com.example.thrive.ui;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import com.example.thrive.data.AppDatabase;
import com.example.thrive.data.CategoryTotal;
import com.example.thrive.data.ExpenseDao;
import com.example.thrive.databinding.ActivitySpendingBinding;
import com.example.thrive.util.DateUtils;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.data.PieEntry;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
public class SpendingActivity extends AppCompatActivity {
    ActivitySpendingBinding b;
    ExpenseDao dao;
    CategoryTotalAdapter adapter;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        b = ActivitySpendingBinding.inflate(getLayoutInflater());
        setContentView(b.getRoot());
        dao = AppDatabase.getInstance(this).expenseDao();
        b.listRv.setLayoutManager(new LinearLayoutManager(this));
        adapter = new CategoryTotalAdapter();
        b.listRv.setAdapter(adapter);
    }
    @Override protected void onResume() {
        super.onResume();
        loadData();
    }
    private void loadData() {
        Executors.newSingleThreadExecutor().execute(() -> {
            List<CategoryTotal> rows = dao.totalsByCategory(DateUtils.monthStartMillis(), DateUtils.monthEndMillis());
            runOnUiThread(() -> {
                adapter.setItems(rows);
                ArrayList<PieEntry> entries = new ArrayList<>();
                for (CategoryTotal ct : rows) entries.add(new PieEntry((float) ct.total, ct.name));
                PieDataSet set = new PieDataSet(entries, "");
                PieData data = new PieData(set);
                b.pieChart.setData(data);
                b.pieChart.setUsePercentValues(true);
                b.pieChart.getDescription().setEnabled(false);
                b.pieChart.getLegend().setEnabled(true);
                b.pieChart.invalidate();
            });
        });
    }
}
