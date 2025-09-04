package com.example.thrive.data;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "expenses")
public class Expense {
    @PrimaryKey(autoGenerate = true)
    public int id;
    public double amount;
    public int categoryId;
    public long dateMillis;
    public String note;
    public Expense(double amount, int categoryId, long dateMillis, String note) {
        this.amount = amount; this.categoryId = categoryId; this.dateMillis = dateMillis; this.note = note;
    }
}
