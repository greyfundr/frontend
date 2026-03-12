import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/features/bill/bill_screen.dart';
import 'package:greyfundr/features/charity/charity_screen.dart';
import 'package:greyfundr/features/event/event_home.dart';
// no bottom nav here; parent BottomNav provides it

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

    // Return only the shell body (no Scaffold) so the app-level BottomNav
    // provided by `BottomNav` remains the single source of truth for
    // bottom navigation. Child screens should not render their own
    // bottomNavigationBar when used inside the main BottomNav view.
    return SafeArea(
      child: Obx(() => IndexedStack(
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