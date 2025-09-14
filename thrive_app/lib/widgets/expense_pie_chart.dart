import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const ExpensePieChart({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No expense data available'),
          ],
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);
    final entries = categoryData.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final categoryEntry = entry.value;
                      final percentage = (categoryEntry.value / total) * 100;
                      
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: categoryEntry.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final categoryEntry = entry.value;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                categoryEntry.key,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
