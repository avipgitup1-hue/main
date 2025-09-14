import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/income.dart';

class AddEditIncomeScreen extends StatefulWidget {
  final Income? income;

  const AddEditIncomeScreen({super.key, this.income});

  @override
  State<AddEditIncomeScreen> createState() => _AddEditIncomeScreenState();
}

class _AddEditIncomeScreenState extends State<AddEditIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  String _selectedSource = 'Salary';
  DateTime _selectedDate = DateTime.now();

  final List<String> _sources = [
    'Salary',
    'Freelance',
    'Investment',
    'Business',
    'Rental',
    'Bonus',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _amountController.text = widget.income!.amount.toString();
      _selectedSource = widget.income!.source;
      _selectedDate = widget.income!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      
      final income = Income(
        id: widget.income?.id,
        userId: widget.income?.userId ?? '',
        amount: double.parse(_amountController.text),
        source: _selectedSource,
        date: _selectedDate,
      );

      bool success;
      if (widget.income == null) {
        success = await dataProvider.createIncome(income);
      } else {
        success = await dataProvider.updateIncome(widget.income!.id!, income);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.income == null ? 'Income added' : 'Income updated'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(dataProvider.error ?? 'Failed to save income'),
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
        title: Text(widget.income == null ? 'Add Income' : 'Edit Income'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return TextButton(
                onPressed: dataProvider.isLoading ? null : _saveIncome,
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
              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Source Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(),
                ),
                items: _sources.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Row(
                      children: [
                        Icon(_getSourceIcon(source), size: 20),
                        const SizedBox(width: 8),
                        Text(source),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSource = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  return ElevatedButton(
                    onPressed: dataProvider.isLoading ? null : _saveIncome,
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
                            widget.income == null ? 'Add Income' : 'Update Income',
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
      case 'rental':
        return Icons.home;
      case 'bonus':
        return Icons.card_giftcard;
      default:
        return Icons.attach_money;
    }
  }
}
