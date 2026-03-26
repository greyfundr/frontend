import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_circular_progress_indicator.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:provider/provider.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/text_style.dart';

class Step4LocationAndVenue extends StatefulWidget {
  const Step4LocationAndVenue({super.key});

  @override
  State<Step4LocationAndVenue> createState() => _Step4LocationAndVenueState();
}

class _Step4LocationAndVenueState extends State<Step4LocationAndVenue> {
  Timer? _debounce;

  void _onSearchChanged(String query, EventProvider provider) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      provider.getAddressSuggestion(query: query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Location & Venue",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Where will your event take place?",
            style: txStyle14.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            labelText: "Venue Name",
            hintText: "e.g. Eko Convention Center",
            controller: provider.venueNameCtrl,
          ),
          const Gap(20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                labelText: "Address",
                hintText: "Search location...",
                controller: provider.locationAddressCtrl,
                onChanged: (value) {
                  _onSearchChanged(value ?? "", provider);
                  return null;
                },
              ),

              ResponsiveState(
                state: provider.addressSuggestionState,
                busyWidget: const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: CustomCircularProgressIndicator(strokeWidth: 4),
                  ),
                ),
                successWidget: Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        provider.addressSuggestions?.predictions?.length ?? 0,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: borderColor),
                    itemBuilder: (context, index) {
                      final prediction =
                          provider.addressSuggestions!.predictions![index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                        ),
                        title: Text(
                          prediction.description ?? "",
                          style: txStyle14,
                        ),
                        onTap: () {
                          provider.locationAddressCtrl.text =
                              prediction.description ?? "";
                          provider.clearAddressSuggestions();
                          // Additional logic to get Lat/Lng from placeId could be added here
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const Gap(20),
          CustomChatTextField(
            hintText: "Location Description (Directions, Parking, etc.)",
            controller: provider.locationDescCtrl,
          ),

          const Gap(80),
        ],
      ),
    );
  }
}
