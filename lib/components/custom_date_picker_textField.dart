import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';

class CustomDatePickerTextFiled extends StatefulWidget {
  final String labelText;
  final Function(DateTime)? onDateChanged;
  final String selectedDate;
  final String hintText;
  final DateTime? initialDate;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final bool isRequired;

  const CustomDatePickerTextFiled({
    super.key,
    required this.labelText,
    required this.onDateChanged,
    required this.selectedDate,
    this.hintText = "Date of birth",
    this.initialDate,
    this.minimumDate,
    this.maximumDate,
    this.isRequired = false,
  });

  @override
  State<CustomDatePickerTextFiled> createState() =>
      _CustomDatePickerTextFiledState();
}

class _CustomDatePickerTextFiledState extends State<CustomDatePickerTextFiled> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showCustomBottomSheet(
          CupertinoDatePickerSheet(
            onDateChanged: widget.onDateChanged,
            initialDate: widget.initialDate,
            minimumDate: widget.minimumDate,
            maximumDate: widget.maximumDate,
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
                    widget.selectedDate.isEmpty
                        ? widget.hintText
                        : formatDateToString(
                            DateTime.parse(widget.selectedDate),
                          ),
                    style: widget.selectedDate.isNotEmpty
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

class CupertinoDatePickerSheet extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final Function(DateTime)? onDateChanged;

  const CupertinoDatePickerSheet({
    super.key,
    this.onDateChanged,
    this.initialDate,
    this.minimumDate,
    this.maximumDate,
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
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select date', style: txStyle16),
                      InkWell(
                        onTap: () {
                          Get.close(1);
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: borderColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(10),
                  Divider(),
                  Gap(10),
                  SizedBox(
                    height: 200,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initialDate ?? DateTime(2000),
                      minimumDate: minimumDate ?? DateTime(1900, 1, 1),
                      maximumDate:
                          maximumDate ??
                          DateTime(
                            DateTime.now().year - 10,
                            DateTime.now().month,
                            DateTime.now().day,
                          ),
                      onDateTimeChanged: (value) => onDateChanged?.call(value),
                    ),
                  ),
                  Gap(30),
                  CustomButton(
                    onTap: () {
                      Get.close(1);
                    },
                    label: "Done",
                  ),
                  Gap(10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
