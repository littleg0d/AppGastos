import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String category;

  @HiveField(4)
  String? description;

  Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    this.description,
  });

  // Predefined categories
  static const List<String> categories = [
    'Comida',
    'Servicios',
    'Transporte',
    'Ocio',
    'Hogar',
    'Otros',
  ];

  // Category colors for UI
  static const Map<String, int> categoryColors = {
    'Comida': 0xFFFF6B6B,
    'Servicios': 0xFF4ECDC4,
    'Transporte': 0xFFFFE66D,
    'Ocio': 0xFFA8E6CF,
    'Hogar': 0xFFFF8B94,
    'Otros': 0xFFC7CEEA,
  };

  // Category icons
  static const Map<String, String> categoryIcons = {
    'Comida': '🍽️',
    'Servicios': '💡',
    'Transporte': '🚗',
    'Ocio': '🎮',
    'Hogar': '🏠',
    'Otros': '📦',
  };

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'category': category,
      'description': description,
    };
  }

  // Create from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      category: json['category'],
      description: json['description'],
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, date: $date, amount: $amount, category: $category, description: $description)';
  }
}
