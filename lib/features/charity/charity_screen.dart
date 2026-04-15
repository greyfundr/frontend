import 'package:flutter/material.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/widgets/charity/tab_selector.dart';

class CharityComponent extends StatefulWidget {
  const CharityComponent({super.key});

  @override
  State<CharityComponent> createState() => _CharityComponentState();
}

class _CharityComponentState extends State<CharityComponent> {
  String selectedTab = 'Explore';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabSelector(
          selectedTab: selectedTab,
          onTabChanged: (tab) => setState(() => selectedTab = tab),
        ),
        Expanded(
          child: UiNoDataAvailableWidget(
            height: SizeConfig.heightOf(30),
            message: "Coming soon",
            subtitle: "You will be notified when this feature is ready ",
          ),
        ),
      ],
    );
  }
}
