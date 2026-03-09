import 'package:flutter/material.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/shared/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
        showErrorToast("New passwords do not match");
        return;
      }

      final provider = Provider.of<AuthProvider>(context, listen: false);
      final success = await provider.changePassword(
        currentPassword: currentPasswordCtrl.text,
        newPassword: newPasswordCtrl.text,
        confirmNewPassword: confirmPasswordCtrl.text,
      );

      if (success) {
        if (!mounted) return;
        currentPasswordCtrl.clear();
        newPasswordCtrl.clear();
        confirmPasswordCtrl.clear();

        showCustomBottomSheet(
          const PasswordChangeSuccessSheet(),
          context,
          isDismissible: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Change Password"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Update Password", style: txStyle27Bold),
              const Gap(8),
              Text(
                "Create a password with at least 6 letters and numbers. It should be something others can't guess.",
                style: txStyle12.copyWith(color: greyTextColor),
              ),
              const Gap(32),

              CustomTextField(
                controller: currentPasswordCtrl,
                hintText: "Old Password",
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  return null;
                },
              ),
              const Gap(16),

              CustomTextField(
                controller: newPasswordCtrl,
                hintText: "New Password",
                obscureText: true,
                onChanged: (val) {
                  authProvider.checkPasswordStrength(val ?? "");
                  return null;
                },
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const Gap(12),
              PasswordStrengthIndicator(
                strength: authProvider.passwordStrength,
              ),
              const Gap(16),

              CustomTextField(
                controller: confirmPasswordCtrl,
                hintText: "Confirm Password",
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  return null;
                },
              ),
              const Gap(40),

              CustomButton(onTap: handleSubmit, label: "Update Password"),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final int strength;
  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        Color color = Colors.grey[300]!;
        if (index < strength) {
          if (strength <= 1) {
            color = Colors.red;
          } else if (strength == 2) {
            color = Colors.orange;
          } else if (strength == 3) {
            color = Colors.amber;
          } else {
            color = Colors.green;
          }
        }
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

class PasswordChangeSuccessSheet extends StatelessWidget {
  const PasswordChangeSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 48, color: Colors.green[700]),
          ),
          const Gap(24),
          Text(
            "Password Updated!",
            style: txStyle20.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(12),
          Text(
            "Your password has been changed successfully. You will now be logged out to protect your account.",
            textAlign: TextAlign.center,
            style: txStyle14.copyWith(color: greyTextColor),
          ),
          const Gap(32),
          CustomButton(
            onTap: () {
              // Navigator.pop(context); // Dismiss the bottom sheet

              logout();
            },
            label: "Okay",
          ),
        ],
      ),
    );
  }
}