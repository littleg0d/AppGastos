import 'package:flutter/material.dart';
import '../models/expense.dart';

class CategoryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const CategoryDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Categoría',
        prefixIcon: Icon(
          Icons.category,
          color: Theme.of(context).colorScheme.primary,
        ),
        errorText: errorText,
      ),
      items: Expense.categories.map((category) {
        final icon = Expense.categoryIcons[category] ?? '📦';
        final color = Color(Expense.categoryColors[category] ?? 0xFF999999);

        return DropdownMenuItem<String>(
          value: category,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(category),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona una categoría';
        }
        return null;
      },
    );
  }
}
