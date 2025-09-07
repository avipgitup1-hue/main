import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/savings_goal.dart';

class AddEditGoalScreen extends StatefulWidget {
  final SavingsGoal? goal;

  const AddEditGoalScreen({super.key, this.goal});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _targetAmountController.text = widget.goal!.targetAmount.toString();
      _currentAmountController.text = widget.goal!.currentAmount.toString();
      _selectedDeadline = widget.goal!.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _clearDeadline() {
    setState(() {
      _selectedDeadline = null;
    });
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      
      final goal = SavingsGoal(
        id: widget.goal?.id,
        userId: widget.goal?.userId ?? '',
        title: _titleController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: double.parse(_currentAmountController.text),
        deadline: _selectedDeadline,
      );

      bool success;
      if (widget.goal == null) {
        success = await dataProvider.createSavingsGoal(goal);
      } else {
        success = await dataProvider.updateSavingsGoal(widget.goal!.id!, goal);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.goal == null ? 'Goal created' : 'Goal updated'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(dataProvider.error ?? 'Failed to save goal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Add Savings Goal' : 'Edit Goal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return TextButton(
                onPressed: dataProvider.isLoading ? null : _saveGoal,
                child: dataProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Emergency Fund, Vacation, New Car',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target Amount Field
              TextFormField(
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Current Amount Field
              TextFormField(
                controller: _currentAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Current Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  hintText: '0.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the current amount (0 if starting fresh)';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Please enter a valid amount';
                  }
                  final targetAmount = double.tryParse(_targetAmountController.text);
                  final currentAmount = double.parse(value);
                  if (targetAmount != null && currentAmount > targetAmount) {
                    return 'Current amount cannot exceed target amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deadline Field
              InkWell(
                onTap: _selectDeadline,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Deadline (Optional)',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedDeadline != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearDeadline,
                          ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  child: Text(
                    _selectedDeadline != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDeadline!)
                        : 'No deadline set',
                    style: TextStyle(
                      color: _selectedDeadline != null ? null : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Progress Preview
              if (_targetAmountController.text.isNotEmpty && _currentAmountController.text.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress Preview',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final target = double.tryParse(_targetAmountController.text) ?? 0;
                          final current = double.tryParse(_currentAmountController.text) ?? 0;
                          final progress = target > 0 ? (current / target) * 100 : 0;
                          
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progress >= 100 ? Colors.green : Colors.blue,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${progress.toStringAsFixed(1)}% complete',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Save Button
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  return ElevatedButton(
                    onPressed: dataProvider.isLoading ? null : _saveGoal,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: dataProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.goal == null ? 'Create Goal' : 'Update Goal',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  );
                },
              ),

              // Error Message
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  if (dataProvider.error != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dataProvider.error!,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
