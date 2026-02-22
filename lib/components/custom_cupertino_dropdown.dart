import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const CustomCupertinoDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  void _showPicker(BuildContext context) {
    int initialIndex = items.indexOf(value);
    if (initialIndex == -1) initialIndex = 0;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     CupertinoButton(
              //       child: const Text('Done'),
              //       onPressed: () => Navigator.of(context).pop(),
              //     ),
              //   ],
              // ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  onSelectedItemChanged: (int selectedItem) {
                    onChanged(items[selectedItem]);
                  },
                  children: List<Widget>.generate(items.length, (int index) {
                    return Center(
                      child: Text(
                        _capitalizeStart(items[index]),
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeStart(String val) {
    if (val.isEmpty) return val;
    return val[0].toUpperCase() + val.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _capitalizeStart(value),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
