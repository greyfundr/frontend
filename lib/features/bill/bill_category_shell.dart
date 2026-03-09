import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/features/bill/bill_screen.dart';
import 'package:greyfundr/features/charity/charity_screen.dart';
import 'package:greyfundr/features/event/event_home.dart';
import 'package:greyfundr/widgets/reusable_bottom_nav.dart';

class BillCategoryShell extends StatelessWidget {
  const BillCategoryShell({super.key});

  @override
  Widget build(BuildContext context) {
    // Use GetX observable for sub-tab index (0 = Bill, 1 = Charity, 2 = Lifestyle)
    final RxInt subIndex = 0.obs;

    // Sync subIndex with current route (optional, but helpful)
    ever(Get.currentRoute.obs, (route) {
      if (route == '/bill') subIndex.value = 0;
      if (route == '/charity') subIndex.value = 1;
      if (route == '/lifestyle') subIndex.value = 2;
    });

    return Scaffold(
      bottomNavigationBar: reusableBottomNav(context),
      body: Obx(() => IndexedStack(
            index: subIndex.value,
            children: const [
              BillScreen(),
              CharityScreen(),
              EventHome(),
            ],
          )),
    );
  }
}