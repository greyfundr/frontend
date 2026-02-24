import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/features/auth/auth_outlet.dart';
import 'package:greyfundr/features/auth/signin_widget.dart';
import 'package:greyfundr/features/auth/signup_role_selection_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';

List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: "Pay,\nTransfer & Split Bills",
    description:
        "Pay, transfer, or split bills with others. Everyone can pitch in—easy, fair, and hassle-free!",
    bgImage: "assets/images/onboarding_1.png",
    arcImage: "assets/images/arc1.png",
    isLast: false,
  ),
  OnboardingItem(
    title: "Donate,\nBack & Champion",
    description:
        "Bills, Campaigns, Causes you believe in so they can attain success in their endeavors",
    bgImage: "assets/images/onboarding_2.png",
    arcImage: "assets/images/arc3.png",
    isLast: false,
  ),
  OnboardingItem(
    title: "",
    description: "",
    bgImage: "assets/images/onboarding_3.jpeg",
    arcImage: "assets/images/arc2.png",
    isLast: true,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < onboardingItems.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _skip() {
    setState(() {
      _currentIndex = onboardingItems.length - 1;
    });
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  Widget _buildQuickActionCard(
    String label,
    String iconPath,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              height: 32,
            ),
            const Gap(12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: txStyle14SemiBold.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = onboardingItems[_currentIndex];
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _previousPage();
          } else if (details.primaryVelocity! < 0) {
            _nextPage();
          }
        },
        child: SizedBox(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          child: Stack(
            children: [
              Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      key: ValueKey(item.bgImage),
                      height: SizeConfig.heightOf(60),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(item.bgImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: SizeConfig.heightOf(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Grey",
                          style: txStyle30SemiBold.copyWith(
                            color: const Color(0xffD0CDCD),
                            fontSize: 60,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Fundr",
                          style: txStyle30SemiBold.copyWith(
                            color: appPrimaryColor,
                            fontSize: 75,
                            height: 0.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
                  ),
                ],
              ),
              Column(
                children: [
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      key: ValueKey(item.arcImage),
                      height: SizeConfig.heightOf(50),
                      width: SizeConfig.screenWidth,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(item.arcImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(SizeConfig.heightOf(8)),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 0.1),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                            child: item.isLast
                                ? Column(
                                    key: const ValueKey("last_page_buttons"),
                                    children: [
                                      const Gap(20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildQuickActionCard(
                                              "Quick Split",
                                              "assets/svgs/quick_split.svg",
                                              () {},
                                            ),
                                          ),
                                          const Gap(15),
                                          Expanded(
                                            child: _buildQuickActionCard(
                                              "Browse Campaign",
                                              "assets/svgs/quick_campaign.svg",
                                              () {},
                                            ),
                                          ),
                                        ],
                                      ),
                                      Gap(SizeConfig.heightOf(5)),
                                      CustomButton(
                                        onTap: () {
                                          Get.to(
                                            AuthOutlet(),
                                            transition: Transition.rightToLeft,
                                          );
                                        },
                                        backgroundColor: appSecondaryColor,
                                        label: "Login",
                                      ),
                                      const Gap(20),
                                      CustomOnTap(
                                        onTap: () {
                                          Get.to(
                                            SignupRoleSelectionScreen(),
                                            transition: Transition.rightToLeft,
                                          );
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Don't have an account? ",
                                            style: txStyle13wt,
                                            children: [
                                              TextSpan(
                                                text: "Sign Up",
                                                style: txStyle13wt.copyWith(
                                                  color: appPrimaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    key: ValueKey(item.title),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: txStyle24SemiBold.copyWith(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(10),
                                      Text(
                                        item.description,
                                        style: txStyle13wt,
                                      ),
                                      Gap(SizeConfig.heightOf(8)),
                                      CustomButton(
                                        onTap: _nextPage,
                                        label: "Next",
                                        backgroundColor: appSecondaryColor,
                                      ),
                                      const Gap(10),
                                      CustomButton(
                                        onTap: _skip,
                                        label: "Skip",
                                        backgroundColor: Colors.transparent,
                                        borderless: true,
                                        borderColor: Colors.transparent,
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String bgImage;
  final String arcImage;
  final bool isLast;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.bgImage,
    required this.arcImage,
    required this.isLast,
  });
}
