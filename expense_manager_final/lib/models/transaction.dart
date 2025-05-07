import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String type; // 'income' or 'expense'

  TransactionModel({
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });
}