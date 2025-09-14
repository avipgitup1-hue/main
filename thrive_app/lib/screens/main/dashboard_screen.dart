import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/dashboard_data.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/expense_pie_chart.dart';
import '../../widgets/goal_progress_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).loadDashboardData();
    });
  }

  Map<String, double> _convertCategoryDataToMap(List<CategoryData> categoryData) {
    final Map<String, double> result = {};
    for (final category in categoryData) {
      result[category.category] = category.amount;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false).refreshData();
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
                    'Error loading dashboard',
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
                    onPressed: () => dataProvider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final dashboardData = dataProvider.dashboardData;
          
          return RefreshIndicator(
            onRefresh: () => dataProvider.refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Monthly Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Income',
                          amount: dashboardData?.currentMonth.totalIncome ?? 0,
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DashboardCard(
                          title: 'Expenses',
                          amount: dashboardData?.currentMonth.totalExpenses ?? 0,
                          icon: Icons.trending_down,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DashboardCard(
                    title: 'Balance',
                    amount: (dashboardData?.currentMonth.totalIncome ?? 0) - (dashboardData?.currentMonth.totalExpenses ?? 0),
                    icon: ((dashboardData?.currentMonth.totalIncome ?? 0) - (dashboardData?.currentMonth.totalExpenses ?? 0)) >= 0 
                      ? Icons.account_balance_wallet 
                      : Icons.warning,
                    color: ((dashboardData?.currentMonth.totalIncome ?? 0) - (dashboardData?.currentMonth.totalExpenses ?? 0)) >= 0 
                      ? Colors.blue 
                      : Colors.orange,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 24),

                  // Savings Goals Progress (using actual goals from DataProvider)
                  if (dataProvider.savingsGoals.isNotEmpty) ...[
                    Text(
                      'Savings Goals',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dataProvider.savingsGoals.length,
                        itemBuilder: (context, index) {
                          final goal = dataProvider.savingsGoals[index];
                          return Container(
                            width: 200,
                            margin: EdgeInsets.only(
                              right: index < dataProvider.savingsGoals.length - 1 ? 12 : 0,
                            ),
                            child: GoalProgressCard(goal: goal),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Expense Breakdown Chart
                  if (dashboardData?.categoryBreakdown.isNotEmpty == true) ...[
                    Text(
                      'Expense Breakdown',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ExpensePieChart(
                        categoryData: _convertCategoryDataToMap(dashboardData?.categoryBreakdown ?? []),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],


                  // Recent Transactions
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Show recent transactions from dashboard data
                  if ((dashboardData?.recentTransactions ?? []).isNotEmpty) ...[
                    ...(dashboardData?.recentTransactions ?? []).take(5).map((transaction) => 
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: transaction.type == 'expense' 
                            ? Colors.red[50] 
                            : Colors.green[50],
                          child: Icon(
                            transaction.type == 'expense' ? Icons.remove : Icons.add,
                            color: transaction.type == 'expense' 
                              ? Colors.red[600] 
                              : Colors.green[600],
                            size: 16,
                          ),
                        ),
                        title: Text(transaction.description),
                        subtitle: Text(DateFormat('MMM dd').format(transaction.date)),
                        trailing: Text(
                          '${transaction.type == 'expense' ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                          style: TextStyle(
                            color: transaction.type == 'expense' 
                              ? Colors.red[600] 
                              : Colors.green[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No recent transactions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
