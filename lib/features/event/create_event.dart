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
import 'package:greyfundr/core/models/user_event_model.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/shared/text_style.dart';

import 'sections/step_1_names_and_co.dart';
import 'sections/step_2_organizers.dart';
import 'sections/step_3_detailed_description.dart';
import 'sections/step_4_location_and_venue.dart';
import 'sections/step_5_financing_and_activities.dart';

class CreateventPage extends StatelessWidget {
  final EventDatum? draftEvent;
  const CreateventPage({super.key, this.draftEvent});

  @override
  Widget build(BuildContext context) {
    // We register the provider once for the whole flow
    return ChangeNotifierProvider(
      create: (_) => EventProvider(draftEvent: draftEvent),
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
  EventProvider? eventProvider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      eventProvider = Provider.of<EventProvider>(context, listen: false);
    });
  }

  void _nextPage(EventProvider provider) async {
    if (provider.currentStep < 4) {
      await provider.nextStep();
    } else {
      // final step
      bool success = await provider.processStepApi();
      if (success) {
        showSuccessToast("Event published successfully");
        eventProvider?.getMyEvents();
        Get.back();
      }
    }
  }

  void _prevPage(EventProvider provider) {
    if (provider.currentStep > 0) {
      provider.previousStep();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final isLastStep = provider.currentStep == 4;

    return Scaffold(
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              enabled: provider.isStepValid,
              onTap: () => _nextPage(provider),
              label: isLastStep ? "Publish Event" : "Next Step",
            ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
            Gap(10),
          ],
        ),
      ),
    );
  }
}
