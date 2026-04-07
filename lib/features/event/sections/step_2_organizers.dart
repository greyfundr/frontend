import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_network_image%20copy.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:provider/provider.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';

class Step2Organizers extends StatelessWidget {
  const Step2Organizers({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Event Organizers",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              CustomOnTap(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  provider.skipStep();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appSecondaryColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Skip",
                    style: txStyle12Bold.copyWith(color: appSecondaryColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Add people managing this event (must be Greyfundr users)",
            style: txStyle14.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            labelText: "Organizer Phone",
            hintText: "Select phone number",
            controller: provider.organizerPhoneCtrl,
            textInputType: TextInputType.phone,
            onChanged: (value) {
              provider.checkPhoneField();
            },
            suffixIcon: CustomOnTap(
              onTap: () async {
                FocusScope.of(context).unfocus();
                try {
                  final granted = await FlutterContacts.requestPermission(
                    readonly: true,
                  );
                  if (!granted) {
                    return;
                  }

                  final contact = await FlutterContacts.openExternalPick();

                  if (contact != null && contact.phones.isNotEmpty) {
                    final phone = contact.phones.first.number;
                    // clean phone to digits and optional leading plus sign.
                    final cleanedToken = phone.replaceAll(RegExp(r'[^0-9+]'), '');
                    
                    provider.organizerPhoneCtrl.text = cleanedToken;
                    provider.checkPhoneField();
                  }
                } catch (e) {
                  log("CONTACT SELECTION ERROR $e");
                  // Ignore picking errors or show snackbar
                }
              },
              child: const Icon(Icons.contacts, color: appPrimaryColor, size: 20),
            ),
          ),
          const Gap(16),

          if (provider.userSearchModel?.isNotEmpty ?? false)
            Column(
              children: [
                // CustomNetworkImageSqr(imageUrl: provider.userSearchModel![0].profilePicture, height: 50, width: 50)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: provider.userSearchModel!.length,
                  itemBuilder: (context, index) {
                    final user = provider.userSearchModel![index];
                    return Row(
                      children: [
                        CustomNetworkImageSqr(
                          imageUrl: "",
                          height: 50,
                          width: 50,
                        ),
                        Gap(15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("${user.firstName} ${user.lastName}"),
                                  Gap(5),
                                  SvgPicture.asset(
                                    "assets/svgs/verified_badge.svg",
                                    height: 15,
                                    color: appSecondaryColor,
                                  ),
                                ],
                              ),
                              Gap(5),
                              Text(
                                "${user.phoneNumber}",
                                style: txStyle13.copyWith(color: greyTextColor),
                              ),
                            ],
                          ),
                        ),
                        CustomOnTap(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            provider.addOrganizer();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appPrimaryColor.withOpacity(.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Add",
                              style: txStyle12Bold.copyWith(
                                color: appPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton.icon(
          //     onPressed: provider.addOrganizer,
          //     icon: const Icon(Icons.add, color: appPrimaryColor),
          //     label: Text(
          //       "Add Organizer",
          //       style: txStyle14.copyWith(
          //         color: appPrimaryColor,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          const Gap(24),

          if (provider.organizers.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.organizers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final org = provider.organizers[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://i0.wp.com/e-quester.com/wp-content/uploads/2021/11/placeholder-image-person-jpg.jpg?fit=820%2C678&ssl=1',
                      ),
                    ),
                    title: Text(
                      "${org.firstName} ${org.lastName}",
                      style: txStyle15.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("${org.phoneNumber}", style: txStyle14),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => provider.removeOrganizer(index),
                    ),
                  );
                },
              ),
            ),

          // const Gap(80),
        ],
      ),
    );
  }
}
