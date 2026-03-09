import 'dart:developer';
import 'dart:io';

import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_circular_progress_indicator.dart';
import 'package:greyfundr/features/auth/auth_outlet.dart';
import 'package:greyfundr/features/auth/signin_widget.dart';
import 'package:greyfundr/features/onboardinf/onboarding_screen.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> doHepticFeedback() async {
  // if (UserLocalStorageService().getUserHapticFeedback()) {
  HapticFeedback.lightImpact();
  // }
}

Future<bool> showCustomBottomSheet(
  Widget bottomSheet,
  BuildContext context, {
  Color? backgroundColor,
  bool isDismissible = true,
}) async {
  await showModalBottomSheet(
    backgroundColor:
        backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
    isScrollControlled: isDismissible,
    isDismissible: isDismissible,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    context: context,
    builder: (context) => bottomSheet,
  );
  return true;
}

String handlePhoneNumber({
  required String phoneNumber,
  Country? selectedCountry,
}) {
  log("Selected country code: ${selectedCountry?.code}");
  if ((selectedCountry?.code.isEmpty ?? true) ||
      selectedCountry?.code == "NG") {
    String number = "+234${phoneNumber.replaceFirst(RegExp(r'^0+'), '')}";
    return number;
  } else {
    String number = "${selectedCountry?.dialCode}$phoneNumber";
    return number;
  }
}

class UiBusyWidget extends StatelessWidget {
  final double? height;

  const UiBusyWidget({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? SizeConfig.heightOf(70),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const CustomCircularProgressIndicator(strokeWidth: 5)],
        ),
      ),
    );
  }
}

class UiErrorWidget extends StatelessWidget {
  final double? height;

  const UiErrorWidget({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? SizeConfig.heightOf(70),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("An error occurred", style: txStyle16Bold),
            Gap(10),
            Text("Please try again later."),
            CustomButton(onTap: () {}, label: ""),
          ],
        ),
      ),
    );
  }
}

class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    
    // Prevent multiple decimal points
    if (cleaned.split('.').length > 2) {
      return oldValue;
    }

    // Limit to 2 decimal places if decimal exists
    if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      if (parts[1].length > 2) {
        return oldValue;
      }
    }

    if (cleaned.isEmpty) return newValue.copyWith(text: '');

    // Parse as double
    final double? value = double.tryParse(cleaned);
    if (value == null) return oldValue;

    // Format with commas and up to 2 decimals
    final formatter = NumberFormat('#,###.##');
    final String formatted = formatter.format(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class UiNoDataAvailableWidget extends StatelessWidget {
  final double height;
  final String? message;
  final String? subtitle;
  final VoidCallback? onTap;
  final String buttonText;
  const UiNoDataAvailableWidget({
    super.key,
    required this.height,
    this.message,
    this.subtitle,
    this.onTap,
    this.buttonText = "---",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svgs/empty_state.svg",
              height: 50,
              color: Get.theme.iconTheme.color,
            ),
            if (message != null) ...[
              Gap(5),
              Text(message!, style: txStyle14, textAlign: TextAlign.center),
            ],
            if (subtitle != null) ...[
              Gap(5),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: txStyle13.copyWith(color: greyTextColor.withOpacity(.6)),
              ),
            ],
            if (onTap != null) ...[
              Gap(20),
              CustomButton(
                onTap: onTap ?? () {},
                label: buttonText,
                width: SizeConfig.widthOf(70),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class UiUserNotLoggedIn extends StatelessWidget {
  final double height;
  final String? message;
  final String? subtitle;
  final VoidCallback? onTap;
  final String buttonText;
  const UiUserNotLoggedIn({
    super.key,
    required this.height,
    this.message,
    this.subtitle,
    this.onTap,
    this.buttonText = "---",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svgs/empty_state.svg",
              height: 50,
              color: Get.theme.iconTheme.color,
            ),
            Gap(5),
            Text("You are currently not logged in", style: txStyle14),
            if (subtitle != null) ...[
              Gap(5),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: txStyle13.copyWith(color: greyTextColor.withOpacity(.6)),
              ),
            ],
            if (onTap != null) ...[
              Gap(20),
              CustomButton(
                onTap: onTap ?? () {},
                label: buttonText,
                width: SizeConfig.widthOf(70),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String formatDate(DateTime date) {
  try {
    return DateFormat('d MMMM yyyy').format(date);
  } catch (e) {
    return 'N/A';
  }
}

// format date to this format e.g if its today, show time, if it was yesterday show "yesterday", else show date in this 11/12/2023
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

bool isYesterday(DateTime date1, DateTime date2) {
  final yesterday = date1.subtract(const Duration(days: 1));
  return yesterday.year == date2.year &&
      yesterday.month == date2.month &&
      yesterday.day == date2.day;
}

String formatDateToDisplayForChat(DateTime date) {
  try {
    final now = DateTime.now();
    if (isSameDay(now, date)) {
      return formatDateToTime(date);
    } else if (isYesterday(now, date)) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  } catch (e) {
    return 'N/A';
  }
}

String formatDateToTime(DateTime date) {
  try {
    return DateFormat('hh:mm a').format(date);
  } catch (e) {
    return 'N/A';
  }
}

String capitalizeFirstText(String value) {
  if (value.isEmpty) return value;
  var result = value[0].toUpperCase();
  for (int i = 1; i < value.length; i++) {
    if (value[i - 1] == " ") {
      result = result + value[i].toUpperCase();
    } else {
      result = result + value[i];
    }
  }
  return result;
}

void logout() {
  UserLocalStorageService().clearUserData();
  Get.offAll(AuthOutlet(), transition: Transition.rightToLeft);
}

String convertStringToCurrency(String amount) {
  final parsedAmount = double.tryParse(amount) ?? 0.0;
  final formattedAmount = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
  ).format(parsedAmount);
  return formattedAmount;
}

String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays >= 365) {
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 30) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 7) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}

class UploadImageOption extends StatelessWidget {
  final VoidCallback fromGallery;
  final VoidCallback fromCamera;

  const UploadImageOption({
    super.key,
    required this.fromGallery,
    required this.fromCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
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
                Text("Upload media from?", style: txStyle16Bold),
                IconButton(
                  onPressed: () {
                    Get.close(1);
                  },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            Gap(30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    fromCamera();
                    Get.close(1);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: appPrimaryColor),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: appPrimaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(10),
                      Text(
                        "Camera",
                        style: txStyle14.copyWith(color: appPrimaryColor),
                      ),
                    ],
                  ),
                ),
                Gap(25),
                InkWell(
                  onTap: () {
                    fromGallery();
                    Get.close(1);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: appPrimaryColor),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, color: appPrimaryColor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(10),
                      Text(
                        "Gallery",
                        textAlign: TextAlign.center,
                        style: txStyle14.copyWith(color: appPrimaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(20),
          ],
        ),
      ),
    );
  }
}

String whatToShowOnEachLecture({
  required bool isFree,
  required bool isEnrolled,
  required int index,
  required int sectionIndex,
}) {
  if (isFree && sectionIndex == 0 && index == 0) {
    return "Free";
  }
  if (!isFree && !isEnrolled && index == 0) {
    return "Preview";
  }
  if (isEnrolled) {
    return "";
  } else {
    return "";
  }
}

bool isAppDarkMode() {
  return Get.isDarkMode;
}

void openUrl({required String url}) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}

String formatDateToString(DateTime date) {
  // Format: yyyy-MM-dd (e.g., 1990-01-01)
  final dateFormat = DateFormat('yyyy-MM-dd');
  return dateFormat.format(date);
}

String formatTimeOfDayToString(DateTime time) {
  final now = DateTime.now();
  final dateTime = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  final dateFormat = DateFormat('hh:mm a');
  return dateFormat.format(dateTime);
}

// convert this time format 10:30 AM to DateTime
DateTime convertTimeStringToDateTime(String timeString) {
  final now = DateTime.now();
  final dateFormat = DateFormat('hh:mm a');
  final time = dateFormat.parse(timeString);
  return DateTime(now.year, now.month, now.day, time.hour, time.minute);
}

// i want a function that takes string value of this type (10 minutes), and a start time in Datetime Format you will do the subtraction and retunr the new DateTime value
DateTime subtractDurationFromTime({
  required String duration,
  required DateTime startTime,
}) {
  log("Subtracting duration: $duration from start time: $startTime");
  final parts = duration.split(' ');
  if (parts.length != 2) {
    throw ArgumentError(
      'Invalid duration format. Expected format: "<number> <unit>"',
    );
  }
  final int value = int.parse(parts[0]);
  final String unit = parts[1].toLowerCase();
  switch (unit) {
    case 'minutes':
    case 'minute':
      return startTime.subtract(Duration(minutes: value));
    case 'hours':
    case 'hour':
      return startTime.subtract(Duration(hours: value));
    case 'days':
    case 'day':
      return startTime.subtract(Duration(days: value));
    default:
      throw ArgumentError(
        'Invalid time unit. Supported units: minutes, hours, days',
      );
  }
}

// convert 01:00 to 1:00 hour, 02:30 to 2hours 30 minutes, 0:30 to 30 minutes
String convertDurationString(String duration) {
  final parts = duration.split(':');
  if (parts.length != 2) {
    throw ArgumentError('Invalid duration format. Expected format: "HH:MM"');
  }
  final int hours = int.parse(parts[0]);
  final int minutes = int.parse(parts[1]);
  String result = '';
  if (hours > 0) {
    result += '$hours hour${hours > 1 ? 's' : ''}';
  }
  if (minutes > 0) {
    if (result.isNotEmpty) {
      result += ' ';
    }
    result += '$minutes minute${minutes > 1 ? 's' : ''}';
  }
  return result;
}

// convertDaysToShortForm(String day) {
//   switch (day.toLowerCase()) {
//     case "monday":
//       return "Mon";
//     case "tuesday":
//       return "Tue";
//     case "wednesday":
//       return "Wd";
//     case "":
//       return "Mon";
//     case "monday":
//       return "Mon";
//     case "monday":
//       return "Mon";
//     case "monday":
//       return "Mon";
//     case "monday":
//       return "Mon";
//     case "monday":
//       return "Mon";
//     case "monday":
//       return "Mon";
//       break;
//     default:
//   }
// }
// i will send the reminder in this format,

/// Opens the platform subscription management page.
/// - [androidPackageName] should be your Android app package (e.g. com.example.app).
/// - [googleSku] is optional — you can include a SKU if you want Play's subscription view to focus on one subscription.
Future<void> openPlatformSubscriptions({
  String androidPackageName = 'com.xlearn.android',
  String? googleSku,
}) async {
  try {
    if (Platform.isIOS) {
      // Prefer to open the App Store subscriptions entry via the itms-apps scheme.
      final Uri iosAppStoreUri = Uri.parse(
        'itms-apps://apps.apple.com/account/subscriptions',
      );
      if (await canLaunchUrl(iosAppStoreUri)) {
        await launchUrl(iosAppStoreUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to web URL
      final Uri iosWebUri = Uri.parse(
        'https://apps.apple.com/account/subscriptions',
      );
      await launchUrl(iosWebUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (Platform.isAndroid) {
      // Play Store subscriptions center — include package and optional sku if provided
      final String base = 'https://play.google.com/store/account/subscriptions';
      final String params =
          '?package=$androidPackageName${googleSku != null ? '&sku=$googleSku' : ''}';
      final Uri playStoreUri = Uri.parse(base + params);

      // Try to open in external application (Play Store or browser)
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to the generic subscriptions page
      final Uri fallback = Uri.parse(base);
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
      return;
    }

    // Other platforms: open a sensible web fallback
    final Uri webFallback = Uri.parse(
      'https://play.google.com/store/account/subscriptions',
    );
    await launchUrl(webFallback, mode: LaunchMode.externalApplication);
  } catch (e) {
    // handle/log error — could show a SnackBar to inform the user
    debugPrint('openPlatformSubscriptions error: $e');
  }
}

// ["00:30", "01:00", "01:30", "02:00", "02:30", "03:00"] => ["30 minutes", "1 hour", "1 hour 30 minutes", "2 hours", "2 hours 30 minutes", "3 hours"]
// i will send individual time strings to be converted e.g 00.30 to 30 minutes, 01:00 to 1 hour, 01:30 to 1 hour 30 minutes
String convertTimeStringToDuration(String timeString) {
  final parts = timeString.split(':');
  if (parts.length != 2) {
    throw ArgumentError('Invalid time format. Expected format: "HH:MM"');
  }
  final int hours = int.parse(parts[0]);
  final int minutes = int.parse(parts[1]);
  String result = '';
  if (hours > 0) {
    result += '$hours hour${hours > 1 ? 's' : ''}';
  }
  if (minutes > 0) {
    if (result.isNotEmpty) {
      result += ' ';
    }
    result += '$minutes minute${minutes > 1 ? 's' : ''}';
  }
  return result;
}

// another that will take 30 minutes and return 00:30, 1 hour 30 minutes to 01:30

String convertDurationToTimeString(String duration) {
  final parts = duration.split(' ');
  int hours = 0;
  int minutes = 0;

  for (int i = 0; i < parts.length; i += 2) {
    final int value = int.parse(parts[i]);
    final String unit = parts[i + 1].toLowerCase();
    if (unit.startsWith('hour')) {
      hours = value;
    } else if (unit.startsWith('minute')) {
      minutes = value;
    }
  }

  final String hoursString = hours.toString().padLeft(2, '0');
  final String minutesString = minutes.toString().padLeft(2, '0');

  return '$hoursString:$minutesString';
}



String formatPhoneNumber(String phoneNumber) {
  if (phoneNumber.isEmpty) return phoneNumber;
  if (phoneNumber.startsWith("+234")) {
    return phoneNumber;
  }
  if (phoneNumber.startsWith('0')) {
    return '+234${phoneNumber.substring(1)}';
  }
  return "+234$phoneNumber";
}