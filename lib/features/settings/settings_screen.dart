import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/features/settings/edit_profile_screen.dart';
import 'package:greyfundr/features/shared/bottom_sheets.dart';
import 'package:greyfundr/shared/utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // TODO: Implement change password screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Password - Coming soon')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            onTap: () {
              // TODO: Implement privacy settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings - Coming soon')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Security',
            onTap: () {
              // TODO: Implement security settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Security settings - Coming soon'),
                ),
              );
            },
          ),

          const Divider(height: 32, thickness: 1),

          // Activity Section
          _buildSectionHeader('Activity'),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Transaction History',
            onTap: () {
              // TODO: Navigate to transaction history screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction History - Coming soon'),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // TODO: Navigate to notification settings
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Notification settings - Coming soon')),
              // );

              // Navigator.push(
              //               context,
              //               MaterialPageRoute(builder: (_) => const NotificationScreen()),
              //             );
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help Center - Coming soon')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // TODO: Navigate to about page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About - Coming soon')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Terms and Conditions',
            onTap: () {
              // TODO: Navigate to terms & conditions
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms & Conditions - Coming soon'),
                ),
              );
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
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => onTap(),
    );
  }
}
