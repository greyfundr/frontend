 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';

void showErrorToast(String message) {
  if (message.isNotEmpty) {
    FToast fToast = FToast();
    fToast.init(Get.overlayContext!);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: criticalColor),
        color: debitColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.new_releases, color: criticalColor, size: 15),

          Gap(10),
          Flexible(
            child: Text(
              message,
              style: txStyle14.copyWith(
                color: Colors.black.withOpacity(.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
          Gap(30),
          InkWell(
            onTap: () {
              fToast.removeCustomToast();
            },
            child: Icon(Icons.close, size: 15),
          ),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: 3),
    );
  }
}

void showSuccessToast(String message, {int? durartion}) {
  FToast fToast = FToast();
  fToast.removeCustomToast();
  fToast.init(Get.overlayContext!);
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: creditColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.task_alt, color: successColor, size: 15),

        Gap(10),
        Flexible(
          child: Text(
            message,
            style: txStyle14.copyWith(
              color: successColor,
             ),
            textAlign: TextAlign.left,
          ),
        ),
        Gap(30),
        InkWell(
          onTap: () {
            fToast.removeCustomToast();
          },
          child: Icon(Icons.close, size: 15),
        ),
      ],
    ),
  );
  fToast.showToast(
    child: toast,
    gravity: ToastGravity.TOP,
    toastDuration: Duration(seconds: durartion ?? 3),
  );
}

void showNotificationsSnackbar(
  String title,
  String message,
  VoidCallback ontap,
  String notificationIcon,
) {
  if (title.isNotEmpty) {
    showSnackbar(
      title,
      message,
      Icons.notifications,
      const Color.fromARGB(255, 98, 98, 98).withOpacity(.5),
      ontap,
      notificationIcon,
    );
  }
}

void showSnackbar(
  String title,
  String message,
  IconData icon,
  Color backgroundColor,
  VoidCallback onTap,
  String notificationIcon,
) {
  Get.snackbar(
    "",
    "",
    titleText: SizedBox.shrink(),
    messageText: Text(
      message,
      style: txStyle14.copyWith(
        fontFamily: "",
        color: Colors.white,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
    ),
    backgroundColor: backgroundColor,
    duration: const Duration(seconds: 5),
    icon: Padding(
      padding: const EdgeInsets.only(left: 10, right: 5),
      child: SvgPicture.asset(notificationIcon),
    ),
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
    snackStyle: SnackStyle.FLOATING,
    colorText: Colors.white,
    shouldIconPulse: false,
    borderRadius: 10,
    onTap: (value) {
      onTap();
    },
  );
}
