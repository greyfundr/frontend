import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_network_image%20copy.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/core/models/user_event_model.dart';
import 'package:greyfundr/features/bill/event_rsvp_page.dart';
import 'package:greyfundr/features/bill/my_event_details_screen.dart';
import 'package:greyfundr/features/bill/rsvp_details_screen.dart';
import 'package:greyfundr/features/event/create_event.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/widgets/lifestyle/tab_selector.dart';
import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  String selectedTab = 'Live Events';

  EventProvider? eventProvider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider?.getAllEvents();
      eventProvider?.getMyEvents();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildTabContent(BuildContext context) {
    if (selectedTab == 'Upcoming') {
      return const UpcomingEventWidget();
    }

    if (selectedTab == 'My Events') {
      return const MyEventWidget();
    }

    if (selectedTab == 'Live Events') {
      return const LiveEventWidget();
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabSelector(
          selectedTab: selectedTab,
          onTabChanged: (tab) => setState(() => selectedTab = tab),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildTabContent(context),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    );
  }
}

class LiveEventWidget extends StatelessWidget {
  const LiveEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    if (eventProvider.allEventsState == ViewState.Busy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (eventProvider.allEventsState == ViewState.NoDataAvailable ||
        (eventProvider.liveEvents?.isEmpty ?? true)) {
      return const Center(child: Text("No live events available"));
    }

    if (eventProvider.allEventsState == ViewState.Error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Failed to load events"),
            TextButton(
              onPressed: () => eventProvider.getAllEvents(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await eventProvider.getAllEvents();
        await eventProvider.getMyEvents();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: eventProvider.liveEvents?.length ?? 0,
        itemBuilder: (context, index) {
          final event = eventProvider.liveEvents![index];
          return LiveEventCard(
            event: event,
            isRsvpedEvent: eventProvider.isRsvpedEvent(event.id),
          );
        },
      ),
    );
  }
}

class UpcomingEventWidget extends StatelessWidget {
  const UpcomingEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    if (eventProvider.allEventsState == ViewState.Busy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (eventProvider.allEventsState == ViewState.NoDataAvailable ||
        (eventProvider.upcomingEvents?.isEmpty ?? true)) {
      return const Center(child: Text("No upcoming events available"));
    }

    if (eventProvider.allEventsState == ViewState.Error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Failed to load events"),
            TextButton(
              onPressed: () => eventProvider.getAllEvents(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await eventProvider.getAllEvents();
        await eventProvider.getMyEvents();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: eventProvider.upcomingEvents?.length ?? 0,
        itemBuilder: (context, index) {
          final event = eventProvider.upcomingEvents![index];
          return LiveEventCard(
            event: event,
            isRsvpedEvent: eventProvider.isRsvpedEvent(event.id),
          );
        },
      ),
    );
  }
}

class MyEventWidget extends StatelessWidget {
  const MyEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return ResponsiveState(
      state: eventProvider.myEventsState,
      busyWidget: UiBusyWidget(),
      noDataAvailableWidget: UiNoDataAvailableWidget(
        height: SizeConfig.heightOf(30),
      ),
      successWidget: RefreshIndicator.adaptive(
        onRefresh: () async {
          await eventProvider.getAllEvents();
          await eventProvider.getMyEvents();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: eventProvider.myEvents?.length ?? 0,
          itemBuilder: (context, index) {
            final event = eventProvider.myEvents![index];
            return LiveEventCard(event: event, isMyEvent: true);
          },
        ),
      ),
    );
  }
}

class LiveEventCard extends StatefulWidget {
  final EventDatum event;
  final bool isMyEvent;
  final bool isRsvpedEvent;
  const LiveEventCard({
    super.key,
    required this.event,
    this.isMyEvent = false,
    this.isRsvpedEvent = false,
  });

  @override
  State<LiveEventCard> createState() => _LiveEventCardState();
}

class _LiveEventCardState extends State<LiveEventCard> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.event.coverImages != null &&
        widget.event.coverImages!.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (_currentPage < widget.event.coverImages!.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (widget.event.amountRaised ?? 0) / (widget.event.targetAmount ?? 1);
    final percent = int.tryParse((progress * 100).toString()) ?? 0;

    return CustomOnTap(
      onTap: () {
        if (!widget.isMyEvent) {
          if (widget.isRsvpedEvent) {
            Get.to(() => RsvpDetailsScreen(eventId: widget.event.id!));
          } else {
            Get.to(() => EventRSVPScreen(eventId: widget.event.id!));
          }
        } else {
          if (widget.event.pageNumber == 4 || widget.event.pageNumber == 5) {
            Get.to(() => MyEventDetailsScreen(eventId: widget.event.id!));
          } else {
            Get.to(() => CreateventPage(draftEvent: widget.event));
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image(s)
            SizedBox(
              height: 180,
              width: double.infinity,
              child:
                  widget.event.coverImages != null &&
                      widget.event.coverImages!.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: widget.event.coverImages!.length,
                      itemBuilder: (context, index) {
                        return CustomNetworkImageSqr(
                          imageUrl: widget.event.coverImages![index],
                          height: 180,
                          width: double.infinity,
                          padding: 0,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : const Center(child: Icon(Icons.image, size: 50)),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.name ?? "Untitled Event",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.event.hashtag != null)
                              Text(
                                "#${widget.event.hashtag?.replaceFirst("#", "")}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (!widget.isMyEvent) {
                            if (widget.isRsvpedEvent) {
                              Get.to(
                                () => RsvpDetailsScreen(
                                  eventId: widget.event.id!,
                                ),
                              );
                            } else {
                              Get.to(
                                () =>
                                    EventRSVPScreen(eventId: widget.event.id!),
                              );
                            }
                          } else {
                            if (widget.event.pageNumber == 4 ||
                                widget.event.pageNumber == 5) {
                              Get.to(
                                () => MyEventDetailsScreen(
                                  eventId: widget.event.id!,
                                ),
                              );
                            } else {
                              Get.to(
                                () => CreateventPage(draftEvent: widget.event),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          widget.isMyEvent
                              ? "Manage"
                              : widget.isRsvpedEvent
                              ? "View Event"
                              : "RSVP",
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),

                  // Amount Raised

                  // Progress Bar
                  if ((widget.event.targetAmount ?? 0) > 0)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        Gap(5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${convertStringToCurrency("${widget.event.amountRaised}")} raised of ${convertStringToCurrency("${widget.event.targetAmount}")}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "$percent%",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ).paddingOnly(bottom: 12),
                      ],
                    ),

                  // Participants
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const Gap(4),
                      Text(
                        "${widget.event.expectedParticipants ?? 0} participants",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
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
    );
  }
}
