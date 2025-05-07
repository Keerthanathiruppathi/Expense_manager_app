import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String _type = 'expense';

  void _addTransaction() {
    final amount = double.tryParse(_amountController.text);
    final category = _categoryController.text.trim();

    if (amount == null || category.isEmpty) return;

    final txn = TransactionModel(
      amount: amount,
      category: category,
      date: DateTime.now(),
      type: _type,
    );

    final box = Hive.box<TransactionModel>('transactions');
    box.add(txn);

    _amountController.clear();
    _categoryController.clear();
    setState(() {});
  }

  Map<String, double> _weeklySummary(String type) {
    final box = Hive.box<TransactionModel>('transactions');
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final Map<String, double> summary = {};

    for (var txn in box.values) {
      if (txn.type == type &&
          txn.date.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        summary[txn.category] = (summary[txn.category] ?? 0) + txn.amount;
      }
    }

    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense Manager")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Type: "),
                DropdownButton<String>(
                  value: _type,
                  onChanged: (val) => setState(() => _type = val!),
                  items: ['income', 'expense']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
                const Spacer(),
                ElevatedButton(onPressed: _addTransaction, child: const Text("Add"))
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<TransactionModel>('transactions').listenable(),
                builder: (context, Box<TransactionModel> box, _) {
                  final incomeSummary = _weeklySummary('income');
                  final expenseSummary = _weeklySummary('expense');

                  return ListView(
                    children: [
                      const Text("Weekly Income by Category", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...incomeSummary.entries.map((e) => ListTile(
                        title: Text(e.key),
                        trailing: Text("\$${e.value.toStringAsFixed(2)}"),
                      )),
                      const SizedBox(height: 10),
                      const Text("Weekly Expenses by Category", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...expenseSummary.entries.map((e) => ListTile(
                        title: Text(e.key),
                        trailing: Text("\$${e.value.toStringAsFixed(2)}"),
                      )),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}