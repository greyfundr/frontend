import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';

class NumPad extends StatelessWidget {
  final Color buttonColor;
  final Color iconColor;
  final Function onDelete;
  final VoidCallback? onBiometricClicked;
  final bool isForLogin;
  final bool showDecimal;
  final Function(String) onValue;

  const NumPad({
    super.key,
    this.isForLogin = false,
    this.buttonColor = Colors.transparent,
    this.iconColor = Colors.black,
    this.showDecimal = false,
    this.onBiometricClicked,
    required this.onDelete,
    required this.onValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 15),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "1",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "2",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "3",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "4",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "5",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "6",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "7",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "8",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "9",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   
                  if (!UserLocalStorageService().getUseLoginBiometricValue())
                    InkWell(
                      onTap: () {
                        log("L:::::::::${UserLocalStorageService().getUseLoginBiometricValue()}");
                      },
                      child: Container(
                        // color: Colors.black,
                        width: SizeConfig.widthOf(7),
                        // height: 20,
                      ),
                    )
                  else if (isForLogin && UserLocalStorageService().getUseLoginBiometricValue())
                    Container(
                      // color: Colors.black26,
                      width: SizeConfig.widthOf(20),
                      height: SizeConfig.heightOf(8),
                      alignment: Alignment.centerLeft,
                      child: CustomOnTap(
                          highlightColor: Colors.white,
                          splashColor: Colors.white,
                          onTap: () => onBiometricClicked!(),
                          child: SvgPicture.asset(
                            Platform.isAndroid
                                ? "assets/svgs/fingerprint.svg"
                                : "assets/svgs/securityBiometric.svg",
                            height: 30,
                            width: 20,
                            // fit: BoxFit.cover,
                            // alignment: Alignment(5, 0),
                          )),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: NumberButton(
                  number: "0",
                  color: buttonColor,
                  onValue: onValue,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // width: SizeConfig.widthOf(7),
                    height: SizeConfig.heightOf(8),
                    child: CustomOnTap(
                      highlightColor: Colors.white,
                      splashColor: Colors.white,
                      onTap: () => onDelete(),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/svgs/backspace.svg",
                          fit: BoxFit.contain,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NumberButton extends StatelessWidget {
  final String number;
  final Color color;
  final Function(String) onValue;

  const NumberButton({
    super.key,
    required this.number,
    required this.onValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      highlightColor: Colors.white,
      splashColor: Colors.white,
      onTap: () {
        onValue(number.toString());
        doHepticFeedback();
      },
      child: Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class PinCodeText extends StatelessWidget {
  final String pin;

  const PinCodeText({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool isFilled = pin.trim().length > index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? appSecondaryColor : borderColor,
          ),
        );
      }),
    );
  }
}
