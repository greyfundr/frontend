import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/models/event_details_model.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/features/payment/payment_method_screen.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

void showEventGiftBottomSheet({
  required BuildContext context,
  required String eventId,
  required EventDetailsModel event,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EventGiftBottomSheet(eventId: eventId, event: event),
  );
}

class EventGiftBottomSheet extends StatefulWidget {
  final String eventId;
  final EventDetailsModel event;

  const EventGiftBottomSheet({
    super.key,
    required this.eventId,
    required this.event,
  });

  @override
  State<EventGiftBottomSheet> createState() => _EventGiftBottomSheetState();
}

class _EventGiftBottomSheetState extends State<EventGiftBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = UserLocalStorageService().getUserData();
      Provider.of<EventProvider>(
        context,
        listen: false,
      ).initGiftForm(defaultProfileUrl: user?.image);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final eventTitle = widget.event.title?.toString().trim() ?? 'this event';
    final amountError = provider.giftAmountError();
    final canContinue = amountError == null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Gap(20),
              Text("Gift this event", style: txStyle18Bold),
              const Gap(6),
              Text(
                'You\'re sending a gift to "$eventTitle"',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const Gap(20),
              _PhotoPicker(provider: provider),
              const Gap(20),
              Text(
                "Amount",
                style: txStyle13.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(8),
              CustomTextField(
                controller: provider.giftAmountController,
                prefix: '₦',
                hintText: '0',
                textInputType: TextInputType.number,
                formatters: MoneyInputFormatter(),
                autoFocus: true,
                onChanged: (val) {
                  setState(() {});
                },
              ),
              const Gap(6),
              Text(
                amountError ?? 'Minimum gift: ₦100',
                style: TextStyle(
                  fontSize: 11,
                  color: amountError != null ? Colors.red : Colors.grey[600],
                ),
              ),
              const Gap(20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: provider.giftHasBehalfOf
                    ? _BehalfOfChip(provider: provider)
                    : _AddBehalfOfButton(provider: provider),
              ),
              const Gap(12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: provider.giftHasComment
                    ? _CommentChip(provider: provider)
                    : _AddCommentButton(provider: provider),
              ),
              const Gap(28),
              CustomButton(
                onTap: () async {
                  if (!canContinue) return;
                  final amount = provider.giftAmount;
                  String? imageUrl;
                  if (provider.giftHasCustomPhoto) {
                    EasyLoading.show(status: 'Uploading photo...');
                    imageUrl = await provider.uploadGiftPhoto();
                    EasyLoading.dismiss();
                  }
                  final extras = provider.buildGiftPayload(imageUrl: imageUrl);
                  Get.back();
                  Get.to(
                    PaymentMethodScreen(
                      type: 'gifting',
                      eventId: widget.eventId,
                      amount: amount,
                      extraPayload: extras.isEmpty ? null : extras,
                    ),
                    transition: Transition.rightToLeft,
                  );
                },
                enabled: canContinue,
                label: "Continue to payment",
                backgroundColor: appPrimaryColor,
              ),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final EventProvider provider;

  const _PhotoPicker({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasCustom = provider.giftHasCustomPhoto;
    final defaultUrl = provider.giftPhotoUrl ?? '';

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showPhotoSourceSheet(context, provider),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: appPrimaryColor.withValues(alpha: 0.08),
                  backgroundImage: hasCustom
                      ? FileImage(File(provider.giftPhotoFile!.path))
                            as ImageProvider
                      : (defaultUrl.isNotEmpty
                            ? NetworkImage(defaultUrl)
                            : null),
                  child: !hasCustom && defaultUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 36,
                          color: appPrimaryColor,
                        )
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: appPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Text(
            hasCustom ? 'Custom photo' : 'Tap to add a photo',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          if (hasCustom)
            GestureDetector(
              onTap: provider.resetGiftPhoto,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Use default',
                  style: TextStyle(
                    fontSize: 11,
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPhotoSourceSheet(BuildContext context, EventProvider provider) {
    showCustomBottomSheet(
      UploadImageOption(
        fromCamera: () => provider.pickGiftPhoto(fromCamera: true),
        fromGallery: () => provider.pickGiftPhoto(fromCamera: false),
      ),
      context,
    );
  }
}

class _AddBehalfOfButton extends StatelessWidget {
  final EventProvider provider;

  const _AddBehalfOfButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openBehalfOfEditor(context, provider),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appPrimaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_add_alt_1, color: appPrimaryColor),
            const Gap(12),
            Text(
              'Gift on behalf of someone',
              style: TextStyle(
                color: appPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BehalfOfChip extends StatelessWidget {
  final EventProvider provider;

  const _BehalfOfChip({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appPrimaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: appPrimaryColor),
          const Gap(12),
          Expanded(
            child: Text(
              'On behalf of ${provider.giftBehalfOfName}',
              style: const TextStyle(
                color: appPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: provider.clearGiftBehalfOf,
            child: const Icon(Icons.close, color: Colors.grey, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AddCommentButton extends StatelessWidget {
  final EventProvider provider;

  const _AddCommentButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCommentEditor(context, provider),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appPrimaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.chat_bubble_outline, color: appPrimaryColor),
            const Gap(12),
            Text(
              'Add a message',
              style: TextStyle(
                color: appPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentChip extends StatelessWidget {
  final EventProvider provider;

  const _CommentChip({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appPrimaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_bubble, color: appPrimaryColor),
          const Gap(12),
          Expanded(
            child: Text(
              provider.giftCommentController.text,
              style: const TextStyle(
                color: appPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: provider.clearGiftComment,
            child: const Icon(Icons.close, color: Colors.grey, size: 18),
          ),
        ],
      ),
    );
  }
}

void _openBehalfOfEditor(BuildContext context, EventProvider provider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BehalfOfPickerSheet(),
  );
}

class _BehalfOfPickerSheet extends StatefulWidget {
  const _BehalfOfPickerSheet();

  @override
  State<_BehalfOfPickerSheet> createState() => _BehalfOfPickerSheetState();
}

class _BehalfOfPickerSheetState extends State<_BehalfOfPickerSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(
        context,
        listen: false,
      ).clearGiftBehalfSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        height: mediaQuery.size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const Gap(12),
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Gap(16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthOf(5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gift on behalf of", style: txStyle16Bold),
                  const Gap(4),
                  Text(
                    "Search by username, phone or email",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Gap(14),
                  CustomTextField(
                    controller: provider.giftBehalfSearchController,
                    hintText: "@username or phone",
                    autoFocus: true,
                    onChanged: (value) =>
                        provider.onGiftBehalfQueryChanged(value ?? ''),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Expanded(
              child: ResponsiveState(
                state: provider.giftBehalfSearchState,
                idleWidget: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      "Start typing to search",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ),
                busyWidget: const UiBusyWidget(height: 120),
                noDataAvailableWidget: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          color: Colors.grey[400],
                          size: 36,
                        ),
                        const Gap(10),
                        Text(
                          "No users found",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                errorWidget: Center(
                  child: Text(
                    "Couldn't search right now",
                    style: TextStyle(color: Colors.red[400], fontSize: 13),
                  ),
                ),
                successWidget: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.widthOf(5),
                    vertical: 8,
                  ),
                  itemCount: provider.giftBehalfSearchResults.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xffEDEFF3)),
                  itemBuilder: (context, index) {
                    final user = provider.giftBehalfSearchResults[index];
                    return InkWell(
                      onTap: () {
                        provider.setGiftBehalfOfUser(user);
                        Get.back();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CustomNetworkImage(
                              imageUrl: user.profile?.image ?? '',
                              radius: 40,
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.username ??
                                        user.firstName ??
                                        'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    user.phoneNumber ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openCommentEditor(BuildContext context, EventProvider provider) {
  final controller = TextEditingController(
    text: provider.giftCommentController.text,
  );
  showCustomBottomSheet(
    Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add a message", style: txStyle16Bold),
            const Gap(6),
            Text(
              "Share something with the host",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const Gap(16),
            CustomTextField(
              controller: controller,
              hintText: "Your message...",
              maxLines: 5,
              autoFocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
            ),
            const Gap(16),
            CustomButton(
              onTap: () {
                provider.setGiftComment(controller.text);
                Get.back();
              },
              label: "Save",
              backgroundColor: appPrimaryColor,
            ),
          ],
        ),
      ),
    ),
    context,
    backgroundColor: Colors.transparent,
  );
}
