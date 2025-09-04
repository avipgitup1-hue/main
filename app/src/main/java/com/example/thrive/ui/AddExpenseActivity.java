package com.example.thrive.ui;
import android.app.DatePickerDialog;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.example.thrive.data.AppDatabase;
import com.example.thrive.data.Category;
import com.example.thrive.data.Expense;
import com.example.thrive.data.ExpenseDao;
import com.example.thrive.databinding.ActivityAddExpenseBinding;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Executors;
public class AddExpenseActivity extends AppCompatActivity {
    ActivityAddExpenseBinding b;
    ExpenseDao dao;
    long selectedDateMillis;
    HashMap<String, Integer> categoryIdByName = new HashMap<>();
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy", Locale.getDefault());
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        b = ActivityAddExpenseBinding.inflate(getLayoutInflater());
        setContentView(b.getRoot());
        dao = AppDatabase.getInstance(this).expenseDao();
        selectedDateMillis = System.currentTimeMillis();
        b.dateTv.setText(fmt.format(selectedDateMillis));
        b.dateTv.setOnClickListener(v -> {
            cal.setTimeInMillis(selectedDateMillis);
            new DatePickerDialog(this,
                    (view, y, m, d) -> {
                        cal.set(y, m, d, 12, 0, 0);
                        selectedDateMillis = cal.getTimeInMillis();
                        b.dateTv.setText(fmt.format(selectedDateMillis));
                    },
                    cal.get(Calendar.YEAR),
                    cal.get(Calendar.MONTH),
                    cal.get(Calendar.DAY_OF_MONTH)).show();
        });
        Executors.newSingleThreadExecutor().execute(() -> {
            List<Category> cats = dao.getAllCategories();
            runOnUiThread(() -> {
                ArrayAdapter<Category> adapter = new ArrayAdapter<Category>(
                        this, android.R.layout.simple_spinner_dropdown_item, cats) {
                    @Override public CharSequence getItem(int position) { return cats.get(position).name; }
                };
                b.categorySp.setAdapter(adapter);
                for (Category c : cats) categoryIdByName.put(c.name, c.id);
            });
        });
        b.saveBtn.setOnClickListener(v -> save());
    }
    private void save() {
        String amountStr = String.valueOf(b.amountEt.getText()).trim();
        if (amountStr.isEmpty()) { b.amountEt.setError("Enter amount"); return; }
        double amount = Double.parseDouble(amountStr);
        String catName = (String) b.categorySp.getSelectedItem();
        int catId = categoryIdByName.get(catName);
        String note = String.valueOf(b.noteEt.getText());
        Executors.newSingleThreadExecutor().execute(() -> {
            dao.insertExpense(new Expense(amount, catId, selectedDateMillis, note));
            runOnUiThread(() -> {
                Toast.makeText(this, "Saved!", Toast.LENGTH_SHORT).show();
                finish();
            });
        });
    }
}
