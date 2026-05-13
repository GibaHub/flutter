class InstallmentModel {
  final String id;
  final String description;
  final double value;
  final String dueDate;
  final String status;

  // Fields for Payment API
  final String prefix;
  final String number;
  final String installment;
  final String type;
  final double interest;
  final bool isSelected;

  InstallmentModel({
    required this.id,
    required this.description,
    required this.value,
    required this.dueDate,
    required this.status,
    this.prefix = '',
    this.number = '',
    this.installment = '',
    this.type = '',
    this.interest = 0.0,
    this.isSelected = false,
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'],
      description: json['description'],
      value: (json['value'] as num).toDouble(),
      dueDate: json['due_date'],
      status: json['status'],
    );
  }

  DateTime get dueDateDt {
    try {
      if (dueDate.contains('/')) {
        final parts = dueDate.split('/');
        if (parts.length == 3) {
          // dd/MM/yyyy
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      // Try ISO or yyyyMMdd
      if (dueDate.length == 8 && !dueDate.contains('-')) {
        // yyyyMMdd
        return DateTime(
          int.parse(dueDate.substring(0, 4)),
          int.parse(dueDate.substring(4, 6)),
          int.parse(dueDate.substring(6, 8)),
        );
      }
      return DateTime.parse(dueDate);
    } catch (e) {
      return DateTime(2999, 12, 31); // Fallback
    }
  }
}
