import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/features/onboardinf/onboarding_screen.dart';
import 'package:greyfundr/features/onboardinf/sign_in_with_pin_screen.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/sizeConfig.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SizeConfig().init(context);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      UserLocalStorageService().isActivated()
          ? goToHome()
          : Get.off(OnboardingScreen(), transition: Transition.rightToLeft);
    });
  }

  Future<void> goToHome() async {
    Get.off(SignInWithPinScreen(), transition: Transition.rightToLeft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
