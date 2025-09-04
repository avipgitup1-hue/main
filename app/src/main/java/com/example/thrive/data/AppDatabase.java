package com.example.thrive.data;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.sqlite.db.SupportSQLiteDatabase;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Executors;
@Database(entities = {Expense.class, Category.class}, version = 1, exportSchema = false)
public abstract class AppDatabase extends RoomDatabase {
    private static volatile AppDatabase INSTANCE;
    public abstract ExpenseDao expenseDao();
    public static AppDatabase getInstance(Context ctx) {
        if (INSTANCE == null) {
            synchronized (AppDatabase.class) {
                if (INSTANCE == null) {
                    INSTANCE = Room.databaseBuilder(ctx.getApplicationContext(),
                            AppDatabase.class, "thrive.db")
                            .addCallback(new Callback() {
                                @Override public void onCreate(@NonNull SupportSQLiteDatabase db) {
                                    super.onCreate(db);
                                    Executors.newSingleThreadExecutor().execute(() -> {
                                        List<Category> cats = Arrays.asList(
                                                new Category("Transport"),
                                                new Category("Shopping"),
                                                new Category("Groceries"),
                                                new Category("Entertainment"),
                                                new Category("Bills"),
                                                new Category("Savings")
                                        );
                                        getInstance(ctx).expenseDao().insertCategories(cats);
                                        long now = System.currentTimeMillis();
                                        getInstance(ctx).expenseDao().insertExpense(new Expense(45.0, 1, now - 2*24*3600*1000L, "Taxi"));
                                        getInstance(ctx).expenseDao().insertExpense(new Expense(120.0, 2, now - 5*24*3600*1000L, "Clothes"));
                                        getInstance(ctx).expenseDao().insertExpense(new Expense(250.0, 3, now - 8*24*3600*1000L, "Groceries"));
                                        getInstance(ctx).expenseDao().insertExpense(new Expense(60.0, 4, now - 10*24*3600*1000L, "Movies"));
                                        getInstance(ctx).expenseDao().insertExpense(new Expense(500.0, 5, now - 15*24*3600*1000L, "Electricity"));
                                        getInstance(ctx).expenseDao().insertExpense(new Expense(300.0, 6, now - 20*24*3600*1000L, "Saved"));
                                    });
                                }
                            })
                            .build();
                }
            }
        }
        return INSTANCE;
    }
}
