import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_cupertino_dropdown.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:provider/provider.dart';

class NotificationPreferenceScreen extends StatefulWidget {
  const NotificationPreferenceScreen({super.key});

  @override
  State<NotificationPreferenceScreen> createState() =>
      _NotificationPreferenceScreenState();
}

class _NotificationPreferenceScreenState
    extends State<NotificationPreferenceScreen> {
  // Campaign Updates
  bool campaignPush = true;
  bool campaignEmail = true;
  bool campaignInApp = true;
  bool campaignSms = false;
  String campaignFrequency = "realtime";

  // Payment Confirmations
  bool paymentPush = true;
  bool paymentEmail = true;
  bool paymentInApp = true;
  bool paymentSms = true;

  // Trust & Achievements
  bool trustPush = true;
  bool trustEmail = true;
  bool trustInApp = true;
  String trustFrequency = "daily";

  void _updatePreferenceBehindTheScene() {
    final payload = {
      "notificationPrefs": {
        "campaignUpdates": {
          "push": campaignPush,
          "email": campaignEmail,
          "inApp": campaignInApp,
          "sms": campaignSms,
          "frequency": campaignFrequency,
        },
        "paymentConfirmations": {
          "push": paymentPush,
          "email": paymentEmail,
          "inApp": paymentInApp,
          "sms": paymentSms,
        },
        "trustAndAchievements": {
          "push": trustPush,
          "email": trustEmail,
          "inApp": trustInApp,
          "frequency": trustFrequency,
        },
      },
    };
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).updateUserNotificationPreference(payload);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Gap(16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchItem(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            width: 50,
            height: 40,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Switch.adaptive(
                value: value,
                activeColor: appPrimaryColor,
                activeTrackColor: appPrimaryColor.withOpacity(.4),
                inactiveTrackColor: Colors.grey[300],
                onChanged: (val) {
                  onChanged(val);
                  _updatePreferenceBehindTheScene();
                },
              ),
            ),
          ),
          // Switch(
          //   value: value,
          //   activeColor: Theme.of(context).primaryColor,
          //   onChanged: (val) {
          //     onChanged(val);
          //     _updatePreferenceBehindTheScene();
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildFrequencyDropdown(
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Frequency",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          CustomCupertinoDropdown(
            value: value,
            items: const ["realtime", "daily", "weekly"],
            onChanged: (val) {
              onChanged(val);
              // Wait for the UI to update with setState inside onChanged before making the API call
              Future.microtask(() => _updatePreferenceBehindTheScene());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(title: "Notification Preferences"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSection("Campaign Updates", [
              _buildSwitchItem(
                "Push Notifications",
                campaignPush,
                (val) => setState(() => campaignPush = val),
              ),
              _buildSwitchItem(
                "Email Notifications",
                campaignEmail,
                (val) => setState(() => campaignEmail = val),
              ),
              _buildSwitchItem(
                "In-App Notifications",
                campaignInApp,
                (val) => setState(() => campaignInApp = val),
              ),
              _buildSwitchItem(
                "SMS Notifications",
                campaignSms,
                (val) => setState(() => campaignSms = val),
              ),
              const Divider(height: 24),
              _buildFrequencyDropdown(
                campaignFrequency,
                (val) => setState(() => campaignFrequency = val ?? "realtime"),
              ),
            ]),
            _buildSection("Payment Confirmations", [
              _buildSwitchItem(
                "Push Notifications",
                paymentPush,
                (val) => setState(() => paymentPush = val),
              ),
              _buildSwitchItem(
                "Email Notifications",
                paymentEmail,
                (val) => setState(() => paymentEmail = val),
              ),
              _buildSwitchItem(
                "In-App Notifications",
                paymentInApp,
                (val) => setState(() => paymentInApp = val),
              ),
              _buildSwitchItem(
                "SMS Notifications",
                paymentSms,
                (val) => setState(() => paymentSms = val),
              ),
            ]),

            _buildSection("Trust & Achievements", [
              _buildSwitchItem(
                "Push Notifications",
                trustPush,
                (val) => setState(() => trustPush = val),
              ),
              _buildSwitchItem(
                "Email Notifications",
                trustEmail,
                (val) => setState(() => trustEmail = val),
              ),
              _buildSwitchItem(
                "In-App Notifications",
                trustInApp,
                (val) => setState(() => trustInApp = val),
              ),
              const Divider(height: 24),
              _buildFrequencyDropdown(
                trustFrequency,
                (val) => setState(() => trustFrequency = val ?? "daily"),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
