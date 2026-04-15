import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/bill/rsvp_success_screen.dart';
import 'package:greyfundr/features/event/event_description_screen.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class EventRSVPScreen extends StatefulWidget {
  final String eventId;
  const EventRSVPScreen({super.key, required this.eventId});

  @override
  State<EventRSVPScreen> createState() => _EventRSVPScreenState();
}

class _EventRSVPScreenState extends State<EventRSVPScreen> {
  EventProvider? eventProvider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider?.getEventById(widget.eventId);
    });
  }

  @override
  void dispose() {
    super.dispose();
    Future.delayed(Duration.zero, () {
      eventProvider?.disposeRsvp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    var event = eventProvider.eventDetailsModel;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: ResponsiveState(
          state: eventProvider.selectedEventState,
          busyWidget: UiBusyWidget(),
          errorWidget: UiErrorWidget(
            onRetry: () {
              eventProvider.getEventById(widget.eventId);
            },
          ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
          successWidget: Column(
            children: [
              Stack(
                children: [
                  CurvedCornerContainer(
                    child: Container(
                      height: SizeConfig.heightOf(50),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(event?.coverImages?.first ?? ""),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: SizeConfig.widthOf(5),
                        // top: SizeConfig.heightOf(5),
                      ),
                      child: SizedBox(
                        height: 40,
                        child: AdaptiveIcons(
                          onTap: () {
                            Get.close(1);
                          },
                          iconName: "arrow.left.circle",
                          iconData: Icons.arrow_back,
                          iconColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Center(
                child: Stack(
                  children: [
                    SizedBox(
                      height: SizeConfig.heightOf(20),
                      child: Image.asset(
                        "assets/images/wedding_crest.png",
                        height: SizeConfig.heightOf(20),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "${event?.name}".toUpperCase(),
                          style: txStyle24SemiBold.copyWith(fontSize: 20),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(20),
              Center(
                child: Text(
                  formatDateToString(event?.startDateTime ?? DateTime.now()),
                  style: txStyle20SemiBold,
                ),
              ),
              // Gap(20),
              Spacer(),

              Text("How Are You Attending?", style: txStyle16SemiBold),
              Gap(10),
              Row(
                children: [
                  Expanded(
                    child: CustomOnTap(
                      onTap: () {
                        showCustomBottomSheet(RSVPOptionSheet(), context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xffFC643A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            SvgPicture.asset("assets/svgs/online.svg"),
                            Gap(5),
                            Text(
                              "Online",
                              style: txStyle16SemiBold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Gap(20),
                  Expanded(
                    child: CustomOnTap(
                      onTap: () {
                        showCustomBottomSheet(
                          RSVPOptionSheet(isOnline: false),
                          context,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),

                        decoration: BoxDecoration(
                          color: Color(0xff00A4AF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/svgs/venue.svg"),
                            Gap(5),
                            Text(
                              "Venue",
                              style: txStyle16SemiBold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
              Gap(20),
              Text(
                "By accessing or responding to an invitation through this application you agree to the invitation terms by the RSVP",
                style: txStyle12,
                textAlign: TextAlign.center,
              ),
              Gap(20),

            ],
          ),
        ),
      ),
    );
  }
}

class RSVPOptionSheet extends StatefulWidget {
  final bool isOnline;
  const RSVPOptionSheet({super.key, this.isOnline = false});

  @override
  State<RSVPOptionSheet> createState() => _RSVPOptionSheetState();
}

class _RSVPOptionSheetState extends State<RSVPOptionSheet> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/bottom_sheet_cureve_right.png"),
        Container(
          color: Color(0xffF1F1F7),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: SizeConfig.heightOf(20),
                        child: Image.asset(
                          "assets/images/wedding_crest.png",
                          height: SizeConfig.heightOf(20),
                        ),
                      ),
                      Positioned(
                        top: SizeConfig.heightOf(9),
                        bottom: 0,
                        left: 30,
                        right: 0,
                        child: Text(
                          "${eventProvider.eventDetailsModel?.name}"
                              .toUpperCase(),
                          style: txStyle24SemiBold.copyWith(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(20),
                Center(
                  child: Text(
                    widget.isOnline
                        ? "You will attend this event online as?"
                        : "You will attend this event at the venue as?",
                    style: txStyle14SemiBold,
                  ),
                ),
                Gap(20),
                CustomOnTap(
                  onTap: () {
                    eventProvider.setNameToRsvp(
                      "registered_name",
                      "${userProvider.userProfileModel?.firstName} ${userProvider.userProfileModel?.lastName}",
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: eventProvider.isSelected("registered_name")
                          ? Color(0xffdaeeee)
                          : borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${userProvider.userProfileModel?.firstName} ${userProvider.userProfileModel?.lastName}",
                            style: txStyle16SemiBold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text("With registered name", style: txStyle12),
                      ],
                    ),
                  ),
                ),
                Gap(20),
                CustomOnTap(
                  onTap: () {
                    eventProvider.setNameToRsvp(
                      "username",
                      "${userProvider.userProfileModel?.username}",
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: eventProvider.isSelected("username")
                          ? Color(0xffdaeeee)
                          : borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${userProvider.userProfileModel?.username}",
                            style: txStyle16SemiBold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        eventProvider.isSelected("username")
                            ? CustomOnTap(
                                onTap: () {
                                  showCustomBottomSheet(
                                    ChangeNameToRsvp(),
                                    context,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appPrimaryColor.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    "Edit",
                                    style: txStyle10SemiBold.copyWith(
                                      color: appPrimaryColor,
                                    ),
                                  ),
                                ),
                              )
                            : Text("Username/Nickname", style: txStyle12),
                      ],
                    ),
                  ),
                ),
                Gap(20),

                CustomOnTap(
                  onTap: () {
                    eventProvider.setNameToRsvp("anonymous", "anonymous");
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: eventProvider.isSelected("anonymous")
                          ? Color(0xffdaeeee)
                          : borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Anonymous",
                            style: txStyle16SemiBold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          !eventProvider.isSelected("anonymous")
                              ? "I don't want my identity to be known"
                              : "🤫",
                          style: txStyle12,
                        ),
                      ],
                    ),
                  ),
                ),
                Gap(20),
                CustomButton(
                  onTap: () async {
                    bool res = await eventProvider.rsvpToEvent(
                      eventId: eventProvider.eventDetailsModel?.id ?? "",
                      payload: {
                        "name": eventProvider.selectedNameValue,
                        "status": widget.isOnline ? "online" : "venue",
                        "guestCount": 1,
                        "note": "",
                      },
                    );
                    if (res) {
                      eventProvider.getAllEvents();
                       Get.off(
                        RsvpSuccessScreen(
                          eventName: "${eventProvider.eventDetailsModel?.name}",
                          nameUsedForRsvp: eventProvider.selectedNameValue,
                          eventId: eventProvider.eventDetailsModel?.id ?? "",
                        ),
                      );
                    }
                  },
                  label: "Continue",
                ),
                Gap(10)
              ],
            ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
          ),
        ),
      ],
    );
  }
}

class ChangeNameToRsvp extends StatefulWidget {
  final bool isOnline;
  const ChangeNameToRsvp({super.key, this.isOnline = false});

  @override
  State<ChangeNameToRsvp> createState() => _ChangeNameToRsvpState();
}

class _ChangeNameToRsvpState extends State<ChangeNameToRsvp> {
  String selectedIdentity = "registered_name";

  bool isSelected(String identity) => selectedIdentity == identity;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/bottom_sheet_cureve_right.png"),
          Container(
            color: Color(0xffF1F1F7),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomOnTap(
                        onTap: () {
                          Get.close(1);
                        },
                        child: Icon(Icons.close),
                      ),
                    ],
                  ),
                  Center(
                    child: Stack(
                      children: [
                        SizedBox(
                          height: SizeConfig.heightOf(20),
                          child: Image.asset(
                            "assets/images/wedding_crest.png",
                            height: SizeConfig.heightOf(20),
                          ),
                        ),
                        Positioned(
                          top: SizeConfig.heightOf(8),
                          bottom: 0,
                          left: 30,
                          right: 0,
                          child: Text(
                            "${eventProvider.eventDetailsModel?.name}"
                                .toUpperCase(),
                            style: txStyle24SemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(20),
                  Center(
                    child: Text(
                      "Enter the name you want to use for this event",
                      style: txStyle14SemiBold,
                    ),
                  ),
                  Gap(20),
                  CustomTextField(
                    hintText: "Enter name",
                    labelText: "Name",
                    autoFocus: true,
                    onChanged: (val) {
                      eventProvider.setNameToRsvp("registered_name", val);
                    },
                    // initialValue: "${userProvider.userProfileModel?.username}",
                  ),
                  Gap(20),

                  CustomButton(
                    onTap: () async {
                      bool res = await eventProvider.rsvpToEvent(
                        eventId: eventProvider.eventDetailsModel?.id ?? "",
                        payload: {
                          "name": eventProvider.selectedNameValue,
                          "status": widget.isOnline ? "online" : "venue",
                          "guestCount": 1,
                          "note": "",
                        },
                      );
                      if (res) {
                        Get.close(1);
                        Get.to(
                          RsvpSuccessScreen(
                            eventName:
                                "${eventProvider.eventDetailsModel?.name}",
                            nameUsedForRsvp: eventProvider.selectedNameValue,
                            eventId: eventProvider.eventDetailsModel?.id ?? "",
                          ),
                        );
                      }
                    },
                    label: "Continue",
                  ),
                  Gap(20),
                ],
              ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
            ),
          ),
        ],
      ),
    );
  }
}

class Edit extends StatelessWidget {
  const Edit({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
