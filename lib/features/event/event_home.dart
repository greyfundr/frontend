import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:greyfundr/features/charity/charity_screen.dart';
import 'package:greyfundr/features/bill/bill_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/widgets/reusable_bottom_nav.dart'; // ← import from Step 2

class EventHome extends StatelessWidget {
  const EventHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: reusableBottomNav(context), // ← keeps bottom nav visible & Bill highlighted
      body: SafeArea(
        child: Column(
          children: [
            // Top header (same style as BillScreen collapsed header)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              color: const Color(0xFF007A74),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (optional - can remove if not needed)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),

                  // Collapsed tabs: Bill | Charity | Lifestyle
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    _headerTabButton('Bill', false, () {
      Get.offNamed('/bill');  // ← replace current route with Bill
    }),
    _headerTabButton('Charity', false, () {
      Get.toNamed('/charity');  // ← push Charity
    }),
    _headerTabButton('Lifestyle', true, null), // active - no action
  ],
),
                    ),
                  ),

                  // Placeholder space (matches BillScreen layout)
                  const SizedBox(width: 48), // to balance back button
                ],
              ),
            ),

            // Main content (your existing placeholder + improved styling)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Events',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your events and stay updated with the latest news and updates.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Placeholder content - you can replace this later
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No events yet!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first event to get started.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Add your "Create Event" navigation here later
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Create event feature coming soon!')),
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                            label: const Text('Create Event'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60), // extra space at bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable tab button (same style as BillScreen header)
  Widget _headerTabButton(String title, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: isActive ? 16 : 14,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: isActive ? 30 : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}