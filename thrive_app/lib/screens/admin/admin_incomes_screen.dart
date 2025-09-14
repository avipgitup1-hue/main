import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../models/income.dart';

class AdminIncomesScreen extends StatefulWidget {
  const AdminIncomesScreen({super.key});

  @override
  State<AdminIncomesScreen> createState() => _AdminIncomesScreenState();
}

class _AdminIncomesScreenState extends State<AdminIncomesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllIncomes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Incomes'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminProvider>().loadAllIncomes();
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading && adminProvider.allIncomes.isEmpty) {
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
                      adminProvider.loadAllIncomes();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (adminProvider.allIncomes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No incomes found'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary Card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            adminProvider.allIncomes.length.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text('Total Incomes'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '\$${adminProvider.allIncomes.fold<double>(0, (sum, income) => sum + income.amount).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text('Total Amount'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Incomes List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: adminProvider.allIncomes.length,
                  itemBuilder: (context, index) {
                    final income = adminProvider.allIncomes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            _getSourceIcon(income.source),
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              '\$${income.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                income.source,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy').format(income.date),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.laptop;
      case 'investment':
        return Icons.trending_up;
      case 'business':
        return Icons.business;
      case 'gift':
        return Icons.card_giftcard;
      case 'bonus':
        return Icons.star;
      default:
        return Icons.attach_money;
    }
  }
}
