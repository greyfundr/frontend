// import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class Expense {
  String name;
  double cost;
  PlatformFile? file;

  Expense({required this.name, required this.cost, this.file});

  // Add copyWith for deep copying
  Expense copyWith({
    String? name,
    double? cost,
    PlatformFile? file,
  }) {
    return Expense(
      name: name ?? this.name,
      cost: cost ?? this.cost,
      file: file ?? this.file,
    );
  }

  bool get isImage =>
      file?.extension?.toLowerCase() == 'jpg' ||
          file?.extension?.toLowerCase() == 'jpeg' ||
          file?.extension?.toLowerCase() == 'png' ||
          file?.extension?.toLowerCase() == 'webp';

  bool get isPdf => file?.extension?.toLowerCase() == 'pdf';

  // Convert object to a Map
  Map<String, dynamic> toJson() => {
    "name": name,
    "cost": cost,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    name: json["name"],
    cost: json["cost"],
    file: json["file"],
  );

  factory Expense.fromMap(Map<String, String> map) {
    return Expense(
      name: map['name']!,
      cost: double.parse(map['amount']!), // Convert string to double

    );
  }

  List<Map<String, String>> convertExpensesToMaps(List<Expense> expenses) {
    return expenses.map((expense) => {
      'name': expense.name, // Assuming 'name' is a property of your Expense class
      'cost': expense.cost.toString(), // Convert amount to string if needed
      // Add other properties as key-value pairs
    }).toList();
  }
}