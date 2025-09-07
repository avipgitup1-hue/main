import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/data_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.loadDashboardData();
      dataProvider.loadExpenses();
      dataProvider.loadIncomes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final dataProvider = Provider.of<DataProvider>(context, listen: false);
              dataProvider.loadDashboardData();
              dataProvider.loadExpenses();
              dataProvider.loadIncomes();
            },
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.isLoading && dataProvider.dashboardData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dataProvider.error != null && dataProvider.dashboardData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading insights',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dataProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      dataProvider.loadDashboardData();
                      dataProvider.loadExpenses();
                      dataProvider.loadIncomes();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await dataProvider.loadDashboardData();
              await dataProvider.loadExpenses();
              await dataProvider.loadIncomes();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spending Prediction Card
                  _buildPredictionCard(dataProvider),
                  const SizedBox(height: 16),

                  // Monthly Trend Chart
                  _buildMonthlyTrendChart(dataProvider),
                  const SizedBox(height: 16),

                  // Category Analysis
                  _buildCategoryAnalysis(dataProvider),
                  const SizedBox(height: 16),

                  // Financial Health Score
                  _buildFinancialHealthScore(dataProvider),
                  const SizedBox(height: 16),

                  // Recommendations
                  _buildRecommendations(dataProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPredictionCard(DataProvider dataProvider) {
    final dashboardData = dataProvider.dashboardData;
    if (dashboardData == null) return const SizedBox.shrink();

    // Simple prediction based on current month's spending
    final currentMonthExpenses = dashboardData.currentMonth.totalExpenses;
    final predictedNextMonth = currentMonthExpenses * 1.05; // 5% increase prediction

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Spending Prediction',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Next Month Prediction',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(predictedNextMonth),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on current spending trends',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendChart(DataProvider dataProvider) {
    final expenses = dataProvider.expenses;
    final incomes = dataProvider.incomes;
    
    if (expenses.isEmpty && incomes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group data by month for the last 6 months
    final now = DateTime.now();
    final months = <DateTime>[];
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }

    final expenseData = <FlSpot>[];
    final incomeData = <FlSpot>[];

    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final monthExpenses = expenses.where((e) => 
        e.date.year == month.year && e.date.month == month.month
      ).fold(0.0, (sum, e) => sum + e.amount);
      
      final monthIncomes = incomes.where((inc) => 
        inc.date.year == month.year && inc.date.month == month.month
      ).fold(0.0, (sum, inc) => sum + inc.amount);

      expenseData.add(FlSpot(i.toDouble(), monthExpenses));
      incomeData.add(FlSpot(i.toDouble(), monthIncomes));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < months.length) {
                            final month = months[value.toInt()];
                            return Text(
                              DateFormat('MMM').format(month),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: expenseData,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: incomeData,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Expenses', Colors.red),
                const SizedBox(width: 16),
                _buildLegendItem('Income', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryAnalysis(DataProvider dataProvider) {
    final dashboardData = dataProvider.dashboardData;
    if (dashboardData == null || dashboardData.categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...dashboardData.categoryBreakdown.take(5).map((category) {
              final percentage = category.percentage;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category.category),
                        Text(currencyFormat.format(category.amount)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(category.category),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialHealthScore(DataProvider dataProvider) {
    final dashboardData = dataProvider.dashboardData;
    if (dashboardData == null) return const SizedBox.shrink();

    // Simple health score calculation
    final income = dashboardData.currentMonth.totalIncome;
    final expenses = dashboardData.currentMonth.totalExpenses;
    final savingsRate = income > 0 ? ((income - expenses) / income) * 100 : 0;
    
    int healthScore = 50; // Base score
    if (savingsRate > 20) healthScore += 30;
    else if (savingsRate > 10) healthScore += 20;
    else if (savingsRate > 0) healthScore += 10;
    else healthScore -= 20;

    healthScore = healthScore.clamp(0, 100);

    Color scoreColor;
    String scoreText;
    if (healthScore >= 80) {
      scoreColor = Colors.green;
      scoreText = 'Excellent';
    } else if (healthScore >= 60) {
      scoreColor = Colors.blue;
      scoreText = 'Good';
    } else if (healthScore >= 40) {
      scoreColor = Colors.orange;
      scoreText = 'Fair';
    } else {
      scoreColor = Colors.red;
      scoreText = 'Needs Improvement';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Health Score',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: healthScore / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$healthScore',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                          Text(
                            scoreText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scoreColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Savings Rate: ${savingsRate.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(DataProvider dataProvider) {
    final dashboardData = dataProvider.dashboardData;
    if (dashboardData == null) return const SizedBox.shrink();

    final recommendations = <String>[];
    
    // Generate recommendations based on data
    final income = dashboardData.currentMonth.totalIncome;
    final expenses = dashboardData.currentMonth.totalExpenses;
    
    if (expenses > income) {
      recommendations.add('Your expenses exceed your income this month. Consider reducing discretionary spending.');
    }
    
    if (dashboardData.categoryBreakdown.isNotEmpty) {
      final topCategory = dashboardData.categoryBreakdown.first;
      final percentage = topCategory.percentage;
      if (percentage > 40) {
        recommendations.add('${topCategory.category} accounts for ${percentage.toStringAsFixed(1)}% of your spending. Consider ways to reduce this category.');
      }
    }
    
    final savingsRate = income > 0 ? ((income - expenses) / income) * 100 : 0;
    if (savingsRate < 10) {
      recommendations.add('Try to save at least 10% of your income. Consider setting up automatic transfers to savings.');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Great job! Your finances look healthy. Keep up the good work!');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[600]),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'entertainment':
        return Colors.purple;
      case 'shopping':
        return Colors.pink;
      case 'utilities':
        return Colors.teal;
      case 'healthcare':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
