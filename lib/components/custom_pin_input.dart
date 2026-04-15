import 'package:flutter/material.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:pinput/pinput.dart';

class PINCodeInput2 extends StatefulWidget {
  final int inputLenght;
  final controller;
  final String? Function(String?)? onChanged;
  final bool hasPasswordVisibility;
  final bool disableField;
  final Function(String)? onComplete;

  const PINCodeInput2({
    super.key,
    this.inputLenght = 4,
    this.controller,
    this.onChanged,
    this.hasPasswordVisibility = false,
    this.disableField = false,
    this.onComplete,
  });

  @override
  State<PINCodeInput2> createState() => _PINCodeInput2State();
}

class _PINCodeInput2State extends State<PINCodeInput2> {
  bool obscurePin = false;

  @override
  Widget build(BuildContext context) {
    return Pinput(
      onCompleted: widget.onComplete ?? (val) {},
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      submittedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      obscureText: obscurePin,
      controller: widget.controller,
      length: widget.inputLenght,
      onChanged: widget.onChanged,
      autofocus: true,
      readOnly: widget.disableField,
    );
  }

  final defaultPinTheme = PinTheme(
    width: SizeConfig.widthOf(15),
    height: 56,
    textStyle: txStyle20Bold,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(7),
    ),
  );
}
