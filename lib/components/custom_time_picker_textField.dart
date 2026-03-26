import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';

class CustomTimePickerTextFiled extends StatefulWidget {
  final String labelText;
  final Function(DateTime)? onTimeChanged;
  final String selectedTime;
  final String hintText;
  final DateTime? initialTime;
  final bool isRequired;

  const CustomTimePickerTextFiled({
    super.key,
    required this.labelText,
    required this.onTimeChanged,
    required this.selectedTime,
    this.hintText = "Select time",
    this.initialTime,
    this.isRequired = false,
  });

  @override
  State<CustomTimePickerTextFiled> createState() =>
      _CustomTimePickerTextFiledState();
}

class _CustomTimePickerTextFiledState extends State<CustomTimePickerTextFiled> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showCustomBottomSheet(
          CupertinoTimePickerSheet(
            onTimeChanged: widget.onTimeChanged,
            initialTime: widget.initialTime,
          ),
          context,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText.isNotEmpty)
            Row(
              children: [
                Text(
                  widget.labelText,
                  style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                ),
                if (widget.isRequired)
                  Text(
                    "*",
                    style: txStyle13.copyWith(color: Colors.red),
                  ).paddingOnly(left: 2),
              ],
            ),
          if (widget.labelText.isNotEmpty) const Gap(5),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              child: Row(
                children: [
                  Text(
                    widget.selectedTime.isEmpty
                        ? widget.hintText
                        : DateFormat.jm().format(
                            DateTime.parse(widget.selectedTime),
                          ),
                    style: widget.selectedTime.isNotEmpty
                        ? txStyle15
                        : txStyle14.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CupertinoTimePickerSheet extends StatelessWidget {
  final DateTime? initialTime;
  final Function(DateTime)? onTimeChanged;

  const CupertinoTimePickerSheet({
    super.key,
    this.onTimeChanged,
    this.initialTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/bottom_sheet_cureve_right.png"),

        Container(
          color: Color(0xffF1F1F7),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthOf(5),
              vertical: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select time', style: txStyle16SemiBold),
                    InkWell(
                      onTap: () {
                        Get.close(1);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: borderColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                const Divider(),
                const Gap(10),
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: initialTime ?? DateTime.now(),
                    onDateTimeChanged: (value) => onTimeChanged?.call(value),
                  ),
                ),
                const Gap(30),
                CustomButton(
                  onTap: () {
                    Get.close(1);
                  },
                  label: "Done",
                ),
                const Gap(10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
