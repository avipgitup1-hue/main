package com.example.thrive.data;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import java.util.List;
@Dao
public interface ExpenseDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    long insertExpense(Expense e);
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertCategories(List<Category> categories);
    @Query("SELECT * FROM categories ORDER BY name")
    List<Category> getAllCategories();
    @Query("SELECT SUM(amount) FROM expenses WHERE dateMillis BETWEEN :start AND :end")
    Double sumExpenses(long start, long end);
    @Query("SELECT c.name AS name, SUM(e.amount) AS total FROM expenses e JOIN categories c ON c.id = e.categoryId WHERE e.dateMillis BETWEEN :start AND :end GROUP BY e.categoryId ORDER BY total DESC")
    List<CategoryTotal> totalsByCategory(long start, long end);
    @Query("SELECT * FROM expenses ORDER BY dateMillis DESC")
    List<Expense> getAllExpenses();
}
