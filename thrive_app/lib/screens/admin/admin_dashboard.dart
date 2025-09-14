import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_users_screen.dart';
import 'admin_expenses_screen.dart';
import 'admin_incomes_screen.dart';
import 'admin_goals_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminProvider>().loadStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading && adminProvider.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${adminProvider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      adminProvider.clearError();
                      adminProvider.loadStats();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = adminProvider.stats;
          if (stats == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      'Total Users',
                      stats.totalUsers.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Total Expenses',
                      stats.totalExpenses.toString(),
                      Icons.money_off,
                      Colors.red,
                    ),
                    _buildStatCard(
                      'Total Incomes',
                      stats.totalIncomes.toString(),
                      Icons.attach_money,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Total Goals',
                      stats.totalGoals.toString(),
                      Icons.flag,
                      Colors.orange,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Financial Overview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFinancialStat(
                                'Total Expenses',
                                '\$${stats.totalExpenseAmount.toStringAsFixed(2)}',
                                Colors.red,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFinancialStat(
                                'Total Income',
                                '\$${stats.totalIncomeAmount.toStringAsFixed(2)}',
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFinancialStat(
                          'Net Balance',
                          '\$${(stats.totalIncomeAmount - stats.totalExpenseAmount).toStringAsFixed(2)}',
                          stats.totalIncomeAmount >= stats.totalExpenseAmount 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Management Options
                Text(
                  'Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildManagementCard(
                      'Manage Users',
                      Icons.people_outline,
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                      ),
                    ),
                    _buildManagementCard(
                      'View Expenses',
                      Icons.money_off_outlined,
                      Colors.red,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminExpensesScreen()),
                      ),
                    ),
                    _buildManagementCard(
                      'View Incomes',
                      Icons.attach_money_outlined,
                      Colors.green,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminIncomesScreen()),
                      ),
                    ),
                    _buildManagementCard(
                      'View Goals',
                      Icons.flag_outlined,
                      Colors.orange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminGoalsScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialStat(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildManagementCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
