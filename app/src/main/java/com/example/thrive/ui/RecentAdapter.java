package com.example.thrive.ui;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.thrive.data.Expense;
import com.example.thrive.databinding.ItemTransactionBinding;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
public class RecentAdapter extends RecyclerView.Adapter<RecentAdapter.VH> {
    List<Expense> items = new ArrayList<>();
    @NonNull @Override public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemTransactionBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false));
    }
    @Override public void onBindViewHolder(@NonNull VH h, int pos) {
        Expense e = items.get(pos);
        h.note.setText(e.note == null ? "" : e.note);
        h.amount.setText(NumberFormat.getCurrencyInstance(Locale.getDefault()).format(e.amount));
        h.date.setText(new SimpleDateFormat("dd MMM yyyy", Locale.getDefault()).format(new Date(e.dateMillis)));
    }
    @Override public int getItemCount(){ return items.size(); }
    public void setItems(List<Expense> newItems){ items = newItems==null? new ArrayList<>() : newItems; notifyDataSetChanged(); }
    static class VH extends RecyclerView.ViewHolder {
        TextView note, amount, date;
        VH(ItemTransactionBinding b){ super(b.getRoot()); note=b.noteTv; amount=b.amountTv; date=b.dateTv; }
    }
}
