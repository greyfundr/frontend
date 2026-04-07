import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/settings/edit_profile_screen.dart';
import 'package:greyfundr/features/settings/change_password_screen.dart';
import 'package:greyfundr/features/settings/change_pin_flow_screen.dart';
import 'package:greyfundr/features/settings/notification_preference_screen.dart';
import 'package:greyfundr/features/settings/transaction_history_screen.dart';
import 'package:greyfundr/features/settings/verification_screen.dart';
import 'package:greyfundr/features/shared/bottom_sheets.dart';
import 'package:greyfundr/services/local_auth.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useLoginBiometric = false;

  @override
  void initState() {
    super.initState();
    _useLoginBiometric = UserLocalStorageService().getUseLoginBiometricValue();
  }

  Future<void> _handleBiometricToggle(bool enabled) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await doHepticFeedback();

    if (!enabled) {
      await UserLocalStorageService().setUseLoginBiometric(false);
      setState(() {
        _useLoginBiometric = false;
      });
      // await authProvider.syncLoginBiometricPreference(false);
      return;
    }

    try {
      // final hasBiometric = await LocalAuth.hasEnrolledBiometrics();
      // if (!hasBiometric) {
      //   await UserLocalStorageService().setUseLoginBiometric(false);
      //   setState(() {
      //     _useLoginBiometric = false;
      //   });
      //   showErrorToast(
      //     'Biometric is unavailable or not enrolled on this device',
      //   );
      //   return;
      // }

      final authenticated = await LocalAuth.authenticateLogin(
        'Use your biometric to login',
        'Enable Biometric Sign In',
      );

      if (!authenticated) {
        await UserLocalStorageService().setUseLoginBiometric(false);
        setState(() {
          _useLoginBiometric = false;
        });
        showErrorToast('Biometric authentication failed or was cancelled');
        return;
      }

      await UserLocalStorageService().setUseLoginBiometric(true);
      setState(() {
        _useLoginBiometric = true;
      });
      showSuccessToast('Sign in with biometric enabled');
    } catch (e, stackTrace) {
      log("$e ::::$stackTrace ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Settings and Activity"),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          _buildSectionHeader('Account'),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Get.to(EditProfileScreen(), transition: Transition.rightToLeft);
            },
          ),
           _buildMenuItem(
            icon: Icons.verified_user_outlined,
            title: 'Verification',
            onTap: () {
              Get.to(VerificationScreen(), transition: Transition.rightToLeft);
            },
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              Get.to(
                const ChangePasswordScreen(),
                transition: Transition.rightToLeft,
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.dialpad_outlined,
            title: 'Change PIN',
            onTap: () {
              Get.to(
                const ChangePinOldScreen(),
                transition: Transition.rightToLeft,
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.fingerprint,
            title: 'Sign in with biometric',
            trailing: Switch.adaptive(
              activeColor: appPrimaryColor,
              value: _useLoginBiometric,
              onChanged: (value) async => _handleBiometricToggle(value),
            ),
            onTap: () async => _handleBiometricToggle(!_useLoginBiometric),
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            onTap: () {
              // TODO: Implement privacy settings
              showSuccessToast('Privacy settings - Coming soon');
            },
          ),

          // _buildMenuItem(
          //   icon: Icons.security_outlined,
          //   title: 'Security',
          //   onTap: () {
          //     // TODO: Implement security settings
          //     showSuccessToast('Security settings - Coming soon');
          //   },
          // ),
          const Divider(height: 32, thickness: 1),

          // Activity Section
          _buildSectionHeader('Activity'),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Transaction History',
            onTap: () {
              Get.to(
                TransactionHistoryScreen(),
                transition: Transition.rightToLeft,
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Get.to(NotificationPreferenceScreen());
            },
          ),

          const Divider(height: 32, thickness: 1),

          // Support Section
          _buildSectionHeader('Support'),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {
              // TODO: Navigate to help center
              showSuccessToast('Help Center - Coming soon');
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // TODO: Navigate to about page
              showSuccessToast('About - Coming soon');
            },
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Terms and Conditions',
            onTap: () {
              // TODO: Navigate to terms & conditions
              showSuccessToast('Terms & Conditions - Coming soon');
            },
          ),

          const Divider(height: 32, thickness: 1),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 26),
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                showCustomBottomSheet(
                  LogoutAppSheet(userName: "Faruq"),
                  context,
                );
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey[700],
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => onTap(),
    );
  }
}
