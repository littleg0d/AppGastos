import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../widgets/category_dropdown.dart';

class AddEditScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String? _selectedCategory;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _amountController = TextEditingController(
        text: widget.expense!.amount.toStringAsFixed(2),
      );
      _descriptionController = TextEditingController(
        text: widget.expense!.description ?? '',
      );
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedCategory = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Gasto' : 'Agregar Gasto'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteExpense,
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 16),
                CategoryDropdown(
                  value: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 12),
                _buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Monto',
        prefixIcon: Icon(
          Icons.attach_money,
          color: Theme.of(context).colorScheme.primary,
        ),
        hintText: '0.00',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        ThousandsSeparatorInputFormatter(),
      ],
      onChanged: (value) {
        // Keep cursor at the end after formatting
        final cursorPosition = _amountController.selection.base.offset;
        setState(() {});
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un monto';
        }
        // Remove thousand separators for validation
        final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
        final amount = double.tryParse(cleanValue);
        if (amount == null || amount <= 0) {
          return 'Por favor ingresa un monto válido';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Fecha',
        prefixIcon: Icon(
          Icons.calendar_today,
          color: Theme.of(context).colorScheme.primary,
        ),
        hintText: 'Selecciona una fecha',
      ),
      controller: TextEditingController(text: dateFormat.format(_selectedDate)),
      onTap: _selectDate,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona una fecha';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descripción (Opcional)',
        prefixIcon: Icon(
          Icons.notes,
          color: Theme.of(context).colorScheme.primary,
        ),
        hintText: 'Agrega una nota...',
      ),
      maxLines: 3,
      maxLength: 200,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveExpense,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        isEditing ? 'Guardar Cambios' : 'Agregar Gasto',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Cancelar',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      // Remove thousand separators before parsing
      final cleanAmount = _amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.parse(cleanAmount);
      final description = _descriptionController.text.trim();

      final expense = Expense(
        id: isEditing ? widget.expense!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        amount: amount,
        category: _selectedCategory!,
        description: description.isEmpty ? null : description,
      );

      if (isEditing) {
        await _db.updateExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gasto actualizado')),
          );
        }
      } else {
        await _db.addExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gasto agregado')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este gasto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && isEditing) {
      await _db.deleteExpense(widget.expense!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto eliminado')),
        );
        Navigator.pop(context);
      }
    }
  }
}

// Custom formatter for thousands separator
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all existing dots and commas
    String cleanText = newValue.text.replaceAll('.', '').replaceAll(',', '');

    // Split by decimal point if exists
    List<String> parts = cleanText.split('');
    String integerPart = '';
    String decimalPart = '';
    bool hasDecimal = false;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i] == '.' || parts[i] == ',') {
        hasDecimal = true;
        // Get remaining as decimal part (max 2 digits)
        if (i + 1 < parts.length) {
          decimalPart = cleanText.substring(i + 1);
          if (decimalPart.length > 2) {
            decimalPart = decimalPart.substring(0, 2);
          }
        }
        integerPart = cleanText.substring(0, i);
        break;
      }
    }

    if (!hasDecimal) {
      integerPart = cleanText;
    }

    // Add thousand separators to integer part
    String formattedInteger = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formattedInteger = '.$formattedInteger';
        count = 0;
      }
      formattedInteger = integerPart[i] + formattedInteger;
      count++;
    }

    // Combine with decimal part
    String formattedText = formattedInteger;
    if (hasDecimal) {
      formattedText += ',$decimalPart';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
