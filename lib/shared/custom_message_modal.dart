// lib/utils/custom_message_modal.dart
import 'package:flutter/material.dart';

class CustomMessageModal {
  static void show({
    required BuildContext context,
    required String message,
    bool isSuccess = true,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove any existing banner/modal
    ScaffoldMessenger.of(context).clearMaterialBanners();

    final color = isSuccess ? const Color(0xFF007A74) : Colors.redAccent;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Create animation controller properly
    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 400),
    );

    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1.5),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.reverse().then((_) => overlayEntry.remove());
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    controller.forward();

    // Auto dismiss
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        controller.reverse().then((_) {
          if (overlayEntry.mounted) overlayEntry.remove();
        });
      }
    });
  }
}
