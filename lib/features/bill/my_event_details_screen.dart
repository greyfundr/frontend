import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/core/models/event_details_model.dart';
import 'package:greyfundr/core/models/user_event_model.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/features/event/create_event.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MyEventDetailsScreen extends StatefulWidget {
  final String eventId;
  const MyEventDetailsScreen({super.key, required this.eventId});

  @override
  State<MyEventDetailsScreen> createState() => _MyEventDetailsScreenState();
}

class _MyEventDetailsScreenState extends State<MyEventDetailsScreen> {
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
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    var event = eventProvider.eventDetailsModel;

    void continueEventFlow({int? targetStep}) {
      if (event == null) return;
      final draftJson = event.toJson();
      final step = targetStep ?? event.pageNumber ?? 0;
      draftJson['pageNumber'] = step.clamp(0, 4);
      final draftEvent = EventDatum.fromJson(draftJson);
      Get.to(() => CreateventPage(draftEvent: draftEvent));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: ResponsiveState(
        state: eventProvider.selectedEventState,
        busyWidget: const UiBusyWidget(),
        errorWidget: UiErrorWidget(
          onRetry: () {
            eventProvider.getEventById(widget.eventId);
          },
        ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
        successWidget: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () {
              return eventProvider.getEventById(widget.eventId);
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Incomplete Event Banner

                  // Hero Section with Gradient
                  Stack(
                    children: [
                      Container(
                        height: SizeConfig.heightOf(35),
                        decoration: BoxDecoration(
                          image: event?.coverImages?.isNotEmpty == true
                              ? DecorationImage(
                                  image: NetworkImage(
                                    event!.coverImages!.first,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: event?.coverImages?.isEmpty == true
                              ? appPrimaryColor.withOpacity(0.1)
                              : null,
                        ),
                      ),
                      // Gradient Overlay
                      Container(
                        height: SizeConfig.heightOf(35),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.6),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                      // Header Actions
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.widthOf(4),
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.black87,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (event?.shareLink != null) {
                                            SharePlus.instance.share(
                                              ShareParams(
                                                text:
                                                    'Check out my event "${event!.name}" on Greyfundr! ${event.shareLink}',
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.share_outlined,
                                            color: appPrimaryColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (event?.isPublished == false)
                                SafeArea(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    margin: EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      border: Border.all(
                                        color: Colors.amber[300]!,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: Colors.amber[700],
                                          size: 20,
                                        ),
                                        Gap(12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Event Not Published",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.amber[900],
                                                ),
                                              ),
                                              Gap(4),
                                              Text(
                                                "Complete the event form to make RSVP and gifting available.",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.amber[800],
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Gap(8),
                                        GestureDetector(
                                          onTap: () {
                                            continueEventFlow();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber[700],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "Complete",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Category Badge
                      Positioned(
                        bottom: 20,
                        left: SizeConfig.widthOf(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: appPrimaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (event?.category?.name ?? "EVENT").toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Content Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.widthOf(4),
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          (event?.name ?? "Event").toUpperCase(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        Gap(8),
                        // Hashtag
                        if (event?.hashtag != null)
                          Text(
                            "#${event!.hashtag!.replaceAll("#", "")}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.3,
                            ),
                          ),
                        Gap(24),

                        // Status Card
                        _buildCompactCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "RSVP PARTICIPANTS",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[500],
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  Gap(6),
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: appPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 50,
                                width: 2,
                                color: Colors.grey[200],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: event?.isPublished == true
                                              ? Colors.green
                                              : Colors.amber[700],
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  (event?.isPublished == true
                                                          ? Colors.green
                                                          : Colors.amber[700])!
                                                      .withOpacity(0.4),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Gap(6),
                                      Text(
                                        "STATUS",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[500],
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(6),
                                  Text(
                                    event?.isPublished == true
                                        ? "Open"
                                        : "Pending",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: event?.isPublished == true
                                          ? Colors.green
                                          : Colors.amber[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Gap(16),

                        // Date & Time Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateBlock(
                                icon: Icons.calendar_today_outlined,
                                label: "STARTS",
                                value: event?.startDateTime != null
                                    ? formatDateToString(event!.startDateTime!)
                                    : "TBD",
                              ),
                            ),
                            Gap(12),
                            Expanded(
                              child: _buildDateBlock(
                                icon: Icons.access_time_outlined,
                                label: "TIME",
                                value: event?.startDateTime != null
                                    ? "${event?.startDateTime?.hour}:${event?.startDateTime?.minute.toString().padLeft(2, '0')} AM"
                                    : "TBD",
                              ),
                            ),
                          ],
                        ),
                        if (event?.endDateTime != null) ...[
                          Gap(12),
                          _buildDateBlock(
                            icon: Icons.event_busy_outlined,
                            label: "ENDS",
                            value: formatDateToString(event!.endDateTime!),
                          ),
                        ],
                        Gap(24),
                        // Financial Info
                        if ((event?.targetAmount ?? 0) > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "FINANCIAL TARGET",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                  letterSpacing: 0.6,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => continueEventFlow(targetStep: 4),
                                child: Text(
                                  "Edit",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: appPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap(10),
                          Wrap(
                            spacing: 5,
                            runSpacing: 10,
                            children: [
                              SizedBox(
                                width: SizeConfig.widthOf(44),
                                child: _buildCompactCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "TARGET",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[500],
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Gap(6),
                                      Text(
                                        convertStringToCurrency(
                                          "${event?.targetAmount}",
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Gap(12),
                              SizedBox(
                                width: SizeConfig.widthOf(44),
                                child: _buildCompactCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "RAISED",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[500],
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Gap(6),
                                      Text(
                                        convertStringToCurrency(
                                          "${event?.amountRaised ?? 0}",
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Gap(12),
                              _buildCompactCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "VISIBILITY",
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[500],
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Gap(6),
                                    Text(
                                      event?.hideDonationAmount == true
                                          ? "Hidden"
                                          : "Visible",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: event?.hideDonationAmount == true
                                            ? Colors.amber[700]
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Gap(24),
                        ],

                        if ((event?.purchasableItems?.isNotEmpty ?? false) ||
                            (event?.activities?.isNotEmpty ?? false)) ...[
                          Text(
                            "EVENT ITEMS",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              letterSpacing: 0.6,
                            ),
                          ),
                          Gap(10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (event != null) {
                                      _showPurchasableItemsBottomSheet(event);
                                    }
                                  },
                                  child: _buildCompactCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "PURCHASABLE ITEMS",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[500],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Gap(6),
                                        Text(
                                          "${event?.purchasableItems?.length ?? 0}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: appPrimaryColor,
                                          ),
                                        ),
                                        Gap(4),
                                        Text(
                                          "Tap to view",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Gap(12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (event != null) {
                                      _showActivitiesBottomSheet(event);
                                    }
                                  },
                                  child: _buildCompactCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "ACTIVITIES",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[500],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Gap(6),
                                        Text(
                                          "${event?.activities?.length ?? 0}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: appPrimaryColor,
                                          ),
                                        ),
                                        Gap(4),
                                        Text(
                                          "Tap to view",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap(24),
                        ],

                        if (((event?.venueCount ?? 0) > 0) ||
                            ((event?.onlineCount ?? 0) > 0)) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "ATTENDANCE",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Text(
                                "VENUE & ONLINE",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: appPrimaryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Gap(10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildAttendanceStatCard(
                                  icon: Icons.location_on_outlined,
                                  label: "VENUE COUNT",
                                  value: "${event?.venueCount}",
                                  accentColor: appPrimaryColor,
                                  helperText: "In-person attendance",
                                ),
                              ),
                              Gap(12),
                              Expanded(
                                child: _buildAttendanceStatCard(
                                  icon: Icons.wifi_outlined,
                                  label: "ONLINE COUNT",
                                  value: "${event?.onlineCount}",
                                  accentColor: Colors.blue,
                                  helperText: "Remote attendance",
                                ),
                              ),
                            ],
                          ),
                          Gap(24),
                        ],

                        // Additional Info
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoPill(
                                label: "DONATIONS",
                                value: "Open",
                                color: appPrimaryColor,
                              ),
                            ),
                            Gap(12),
                            Expanded(
                              child: _buildInfoPill(
                                label: "VISIBILITY",
                                value: event?.visibilityStatus == "private"
                                    ? "Private"
                                    : "Public",
                                color: Colors.blue,
                              ),
                            ),
                            Gap(12),
                            Expanded(
                              child: _buildInfoPill(
                                label: "STATUS",
                                value: event?.isPublished == true
                                    ? "Open"
                                    : "Pending",
                                color: event?.isPublished == true
                                    ? Colors.green
                                    : Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        Gap(24),

                        // Location Card
                        if (event?.location != null ||
                            event?.venueName != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "VENUE",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                  letterSpacing: 0.6,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => continueEventFlow(targetStep: 3),
                                child: Text(
                                  "Edit",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: appPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap(10),
                          _buildCompactCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: appPrimaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: appPrimaryColor,
                                    size: 20,
                                  ),
                                ),
                                Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event?.venueName ?? "Venue",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Gap(4),
                                      Text(
                                        event?.location?.address ??
                                            "No address specified",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (event
                                              ?.location
                                              ?.locationDescription !=
                                          null) ...[
                                        Gap(4),
                                        Text(
                                          event!.location!.locationDescription!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: appPrimaryColor,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(24),
                        ],

                        // About Section
                        if (event?.shortDescription != null &&
                            event!.shortDescription!.isNotEmpty) ...[
                          Text(
                            "ABOUT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              letterSpacing: 0.6,
                            ),
                          ),
                          Gap(10),
                          _buildCompactCard(
                            child: Text(
                              event.shortDescription!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                height: 1.6,
                              ),
                            ),
                          ),
                          Gap(24),
                        ],

                        // Detailed Description
                        if (event?.detailedDescription != null &&
                            event!.detailedDescription!.isNotEmpty) ...[
                          Text(
                            "EVENT STORY",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              letterSpacing: 0.6,
                            ),
                          ),
                          Gap(10),
                          ...event.detailedDescription!.map((section) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildCompactCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            section.title?.isNotEmpty == true
                                                ? section.title!
                                                : "Section",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              continueEventFlow(targetStep: 2),
                                          child: Text(
                                            "Edit",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: appPrimaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(8),
                                    Text(
                                      section.text ?? "",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          Gap(12),
                        ],

                        Gap(40),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                onTap: () {
                                  continueEventFlow();
                                },
                                label: "Edit event",
                              ),
                            ),
                            Gap(12),
                            GestureDetector(
                              onTap: () {
                                if (event?.shareLink != null) {
                                  // Clipboard.setData(
                                  //   ClipboardData(text: event!.shareLink!),
                                  // );
                                  // showSuccessToast("Link copied!");
                                  SharePlus.instance.share(
                                    ShareParams(
                                      text:
                                          'Check out my event "${event!.name}" on Greyfundr! ${event.shareLink}',
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.share_outlined,
                                  color: appPrimaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Bottom Action Bar
      // bottomNavigationBar: Container(
      //   padding: EdgeInsets.all(16),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.05),
      //         blurRadius: 10,
      //         offset: const Offset(0, -2),
      //       ),
      //     ],
      //   ),
      //   child: Row(
      //     children: [
      //       GestureDetector(
      //         onTap: () {
      //           // Navigate to create event screen for editing
      //           Get.to(() => const CreateventPage());
      //         },
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(vertical: 14),
      //           decoration: BoxDecoration(
      //             color: appPrimaryColor,
      //             borderRadius: BorderRadius.circular(28),
      //             boxShadow: [
      //               BoxShadow(
      //                 color: appPrimaryColor.withOpacity(0.3),
      //                 blurRadius: 8,
      //                 offset: const Offset(0, 2),
      //               ),
      //             ],
      //           ),
      //           child: Center(
      //             child: Text(
      //               "Edit Event",
      //               style: TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 15,
      //                 fontWeight: FontWeight.w600,
      //                 letterSpacing: 0.3,
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //       Gap(12),
      //       GestureDetector(
      //         onTap: () {
      //           if (event?.shareLink != null) {
      //             Clipboard.setData(ClipboardData(text: event!.shareLink!));
      //             showSuccessToast("Link copied!");
      //           }
      //         },
      //         child: Container(
      //           height: 52,
      //           width: 52,
      //           decoration: BoxDecoration(
      //             color: Colors.grey[100],
      //             borderRadius: BorderRadius.circular(16),
      //             border: Border.all(color: Colors.grey[200]!, width: 1),
      //           ),
      //           child: Icon(
      //             Icons.share_outlined,
      //             color: appPrimaryColor,
      //             size: 20,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  void _showPurchasableItemsBottomSheet(EventDetailsModel event) {
    showCustomBottomSheet(
      Container(
        color: const Color(0xffF1F1F7),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthOf(5),
              vertical: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Purchasable Items",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(8),
                if (!(event.purchasableItems?.isNotEmpty ?? false))
                  Text(
                    "No purchasable items added yet.",
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: SizeConfig.heightOf(45),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: event.purchasableItems!.length,
                      separatorBuilder: (_, __) => const Gap(10),
                      itemBuilder: (context, index) {
                        final raw = event.purchasableItems![index];
                        final item = raw is Map<String, dynamic>
                            ? raw
                            : Map<String, dynamic>.from(raw as Map);
                        final imagesRaw = item['images'];
                        String? firstImage;
                        if (imagesRaw is List && imagesRaw.isNotEmpty) {
                          firstImage = imagesRaw.first.toString();
                        }
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              if (firstImage != null && firstImage.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    firstImage,
                                    width: 42,
                                    height: 42,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                  ),
                                ),
                              const Gap(10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name']?.toString() ?? 'Item',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      "${convertStringToCurrency((item['price'] ?? 0).toString())} • Qty: ${(item['quantity'] ?? 0)}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      context,
      backgroundColor: Colors.transparent,
    );
  }

  void _showActivitiesBottomSheet(EventDetailsModel event) {
    showCustomBottomSheet(
      Container(
        color: const Color(0xffF1F1F7),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthOf(5),
              vertical: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Activities",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(8),
                if (!(event.activities?.isNotEmpty ?? false))
                  Text(
                    "No activities added yet.",
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: SizeConfig.heightOf(45),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: event.activities!.length,
                      separatorBuilder: (_, __) => const Gap(10),
                      itemBuilder: (context, index) {
                        final activity = event.activities![index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((activity.image ?? '').isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    activity.image!,
                                    width: 42,
                                    height: 42,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.event_note_outlined),
                                ),
                              const Gap(10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.name ?? 'Activity',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      activity.description ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      "Goal: ${convertStringToCurrency((activity.targetAmount ?? 0).toString())}",
                                      style: TextStyle(
                                        color: appPrimaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      context,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCompactCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAttendanceStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
    required String helperText,
  }) {
    return _buildCompactCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          Gap(10),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
          Gap(4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Gap(4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBlock({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return _buildCompactCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: appPrimaryColor),
              Gap(6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Gap(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return _buildCompactCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
