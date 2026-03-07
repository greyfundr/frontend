// lib/screens/campaign/widgets/date_range_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef DateRangeCallback = void Function(DateTime start, DateTime end);

class DateRangeSection extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final DateRangeCallback onDateRangeSelected;

  const DateRangeSection({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangeSection> createState() => _DateRangeSectionState();
}

class _DateRangeSectionState extends State<DateRangeSection> {
  Future<void> _selectDateRange() async {
    final DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: widget.startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.teal),
        ),
        child: child!,
      ),
    );

    if (!mounted || pickedStart == null) return;

    final DateTime? pickedEnd = await showDatePicker(
      context: context,
      initialDate: widget.endDate ?? pickedStart.add(const Duration(days: 7)),
      firstDate: pickedStart,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.teal),
        ),
        child: child!,
      ),
    );

    if (!mounted || pickedEnd == null) return;

    widget.onDateRangeSelected(pickedStart, pickedEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(' Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateRange,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _dateColumn(
                    'Start Date',
                    widget.startDate,
                    TextAlign.start,
                  ),
                ),
                const Icon(Icons.swap_horiz, color: Colors.teal, size: 28),
                Expanded(
                  child: _dateColumn(
                    'End Date',
                    widget.endDate,
                    TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _dateColumn(String label, DateTime? date, TextAlign align) {
    return Column(
      crossAxisAlignment:
          align == TextAlign.start ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          date == null ? 'DD/MM/YYYY' : DateFormat('dd MMM yyyy').format(date),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: date == null ? Colors.grey.shade400 : Colors.black,
          ),
        ),
      ],
    );
  }
}
