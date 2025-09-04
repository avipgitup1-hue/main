package com.example.thrive.ui;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.thrive.databinding.ItemCategoryTotalBinding;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
public class CategoryTotalAdapter extends RecyclerView.Adapter<CategoryTotalAdapter.VH> {
    List<com.example.thrive.data.CategoryTotal> items = new ArrayList<>();
    @NonNull @Override public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemCategoryTotalBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false));
    }
    @Override public void onBindViewHolder(@NonNull VH h, int pos) {
        com.example.thrive.data.CategoryTotal ct = items.get(pos);
        h.name.setText(ct.name);
        h.amount.setText(NumberFormat.getCurrencyInstance(Locale.getDefault()).format(ct.total));
    }
    @Override public int getItemCount(){ return items.size(); }
    public void setItems(List<com.example.thrive.data.CategoryTotal> newItems){ items = newItems==null? new ArrayList<>() : newItems; notifyDataSetChanged(); }
    static class VH extends RecyclerView.ViewHolder { TextView name, amount; VH(ItemCategoryTotalBinding b){ super(b.getRoot()); name=b.nameTv; amount=b.amountTv; } }
}
