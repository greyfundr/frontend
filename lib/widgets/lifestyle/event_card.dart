import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:greyfundr/features/charity/campaigndetails.dart';
import 'package:greyfundr/shared/custom_message_modal.dart';
import 'package:greyfundr/widgets/campaigndetails/manage_campaign_bottom_sheet.dart';
import 'package:greyfundr/widgets/campaigndetails/donation_bottom_sheet.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final String? currentUserId;
  final VoidCallback? onDonationSuccess;

  const EventCard({
    super.key,
    required this.campaign,
    this.currentUserId,
    this.onDonationSuccess,
  });

  String _formatNumber(double number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return NumberFormat("#,###").format(number);
  }

  //   void _showSuccessDonationDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // optional: user must tap button to close
  //     builder: (BuildContext dialogContext) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  //         elevation: 0,
  //         backgroundColor: Colors.transparent,
  //         child: Container(
  //           padding: const EdgeInsets.all(28),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(24),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.15),
  //                 blurRadius: 20,
  //                 offset: const Offset(0, 10),
  //               ),
  //             ],
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // Animated character / illustration
  //               SizedBox(
  //                 height: 140,
  //                 child: Image.asset(
  //                   'assets/animations/success.gif', // ← put your Lottie, GIF or static image here
  //                   fit: BoxFit.contain,
  //                 ),
  //               ),

  //               const SizedBox(height: 20),

  //               const Text(
  //                 "Thank You!",
  //                 style: TextStyle(
  //                   fontSize: 28,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color(0xFF007A74),
  //                 ),
  //               ),

  //               const SizedBox(height: 12),

  //               Text(
  //                 "Your donation was successful\nand will make a real difference ❤️",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.grey[800],
  //                   height: 1.4,
  //                 ),
  //               ),

  //               const SizedBox(height: 32),

  //               // Close button
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.of(dialogContext).pop(); // close dialog
  //                     // Optional: navigate or refresh something here
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color(0xFF007A74),
  //                     foregroundColor: Colors.white,
  //                     padding: const EdgeInsets.symmetric(vertical: 16),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(16),
  //                     ),
  //                     elevation: 0,
  //                   ),
  //                   child: const Text(
  //                     "Close",
  //                     style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final double currentAmount =
        double.tryParse(campaign['current_amount'].toString()) ?? 0.0;
    final double goalAmount =
        double.tryParse(campaign['goal_amount'].toString()) ?? 1.0;
    final double progressValue = goalAmount > 0
        ? (currentAmount / goalAmount).clamp(0.0, 1.0)
        : 0.0;
    final int progressPercent = (progressValue * 100).round();

    final DateTime? endDate = DateTime.tryParse(campaign['end_date'] ?? '');
    final int daysLeft = endDate != null
        ? endDate.difference(DateTime.now()).inDays
        : 0;
    final String daysText = daysLeft <= 0
        ? "Expired"
        : daysLeft == 1
        ? "1 Day left"
        : "$daysLeft Days left";

    final bool isUrgent = daysLeft <= 3 && daysLeft > 0;

    // ── Determine if current user owns this campaign ───────────────────────
    final int? creatorId = campaign['creator_id'] as int?;
    final bool isOwner = currentUserId != null && currentUserId == creatorId;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CampaignDetails(id: campaign['id'].toString()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Timer Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    // "https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/${campaign['image']}",
                    "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=1000&auto=format&fit=crop",

                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 500,
                    filterQuality: FilterQuality.low,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(height: 150, color: Colors.grey[200]),
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: daysLeft <= 0
                          ? Colors.grey[800]
                          : (isUrgent ? Colors.red : Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          daysLeft <= 0 ? Icons.timer_off : Icons.access_time,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          daysText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text: '₦${_formatNumber(currentAmount)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' raised of ₦${_formatNumber(goalAmount)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          if (isOwner) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ManageCampaignBottomSheet(
                                campaignId: campaign['id']?.toString() ?? '0',
                                campaign:
                                    campaign, // optional, but useful for EditCampaignLive
                                onRefreshNeeded: () {
                                  // This callback is called after successful edit/delete/etc.
                                  // → refresh the campaign card / list
                                  onDonationSuccess
                                      ?.call(); // re-use your existing callback (if it refreshes the UI)
                                  // If the above doesn't refresh → you can add more logic here later
                                },
                              ),
                            );
                          } else {
                            if (currentUserId == null || currentUserId == 0) {
                              CustomMessageModal.show(
                                context: context,
                                message: "Please sign in to donate",
                                isSuccess: true,
                              );
                              return;
                            }

                            // showModalBottomSheet(
                            //   context: context,
                            //   isScrollControlled: true,
                            //   backgroundColor: Colors.transparent,
                            //   builder: (context) => DonationBottomSheet(
                            //     userId: currentUserId!,
                            //     creatorId: campaign['creator_id'] as int? ?? 0,
                            //     campaignId: campaign['id'] as int? ?? 0,
                            //     campaign: campaign,
                            //     onDonationSuccess: () {
                            //       onDonationSuccess?.call();

                            //       // CustomMessageModal.show(
                            //       //   context: context,
                            //       //   message: "Thank you for your donation",
                            //       //   isSuccess: true,
                            //       // );

                            //       _showSuccessDonationDialog(context);   // ← pass context here

                            //     },
                            //   ),
                            // );

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DonationBottomSheet(
                                campaign:
                                    campaign, // ← only this is needed (optional)
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOwner
                              ? Colors.orangeAccent[700]
                              : Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          isOwner ? 'Manage' : 'Send Gift',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF007A74),
                      ),
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${campaign['donors'] ?? 0} Guests',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${campaign['champions'] ?? 0} Gifts',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const Spacer(),
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007A74),
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
