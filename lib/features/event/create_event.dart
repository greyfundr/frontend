import 'dart:developer';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:provider/provider.dart';

import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';

import 'sections/step_1_names_and_co.dart';
import 'sections/step_2_organizers.dart';
import 'sections/step_3_detailed_description.dart';
import 'sections/step_4_location_and_venue.dart';
import 'sections/step_5_financing_and_activities.dart';

class CreateventPage extends StatelessWidget {
  const CreateventPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We register the provider once for the whole flow
    return ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: const _CreateEventContent(),
    );
  }
}

class _CreateEventContent extends StatefulWidget {
  const _CreateEventContent();

  @override
  State<_CreateEventContent> createState() => _CreateEventContentState();
}

class _CreateEventContentState extends State<_CreateEventContent> {
  bool _canPop = false;

  void _nextPage(EventProvider provider) {
    if (provider.currentStep < 4) {
      provider.nextStep();
    } else {
      // Submit
      provider.createEvent();
    }
  }

  void _prevPage(EventProvider provider) async {
    if (provider.currentStep > 0) {
      provider.previousStep();
    } else {
      final shouldExit = await _showExitWarning();
      if (shouldExit == true) {
        setState(() {
          _canPop = true;
        });
        if (mounted) {
          Get.back();
        }
      }
    }
  }

  Future<bool?> _showExitWarning() {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Clear Progress?",
                style: txStyle16.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(16),
              Text(
                "Are you sure you want to go back? All your entered event data will be lost.",
                textAlign: TextAlign.center,
                style: txStyle14.copyWith(color: Colors.grey[700]),
              ),
              const Gap(32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Cancel",
                        style: txStyle14.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Yes, clear it",
                        style: txStyle14.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10), // Safe area margin
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final isLastStep = provider.currentStep == 4;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _prevPage(provider);
      },
      child: Scaffold(
        backgroundColor: Color(0xffFBFBFF),
        appBar: CustomAppBar(
          title: "Create Event",
          onBack: () => _prevPage(provider),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Gap(10),
              // Elegant Stepper Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= provider.currentStep
                            ? appPrimaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const Gap(10),

              // Main Content
              ExpandablePageView(
                controller: provider.pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Managed by buttons
                children: const [
                  Step1NamesAndCo(),
                  Step2Organizers(),
                  Step3DetailedDescription(),
                  Step4LocationAndVenue(),
                  Step5FinancingAndActivities(),
                ],
              ),
              Gap(10),
              CustomButton(
                onTap: () => _nextPage(provider),
                label: isLastStep ? "Publish Event" : "Next Step",
              ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
            ],
          ),
        ),
      ),
    );
  }
}
