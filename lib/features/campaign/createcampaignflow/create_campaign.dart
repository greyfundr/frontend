import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/components/dotted_border.dart';
import 'package:greyfundr/components/custom_date_picker_textField.dart'
    show CupertinoDatePickerSheet;
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/budget_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';
import 'package:greyfundr/features/campaign/createcampaignflow/review_campaign.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CampaignProvider>(context, listen: false);
      provider.fetchCategories();
      provider.fetchUsers();
    });
  }

  Future<void> _pickImages(CampaignProvider provider) async {
    final remaining =
        CampaignProvider.maxImages - provider.selectedImages.length;
    if (remaining <= 0) {
      showErrorToast('Max ${CampaignProvider.maxImages} images allowed');
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    provider.addImages(picked.take(remaining).map((x) => File(x.path)).toList());
  }

  void _openCategorySheet(BuildContext context) {
    showCustomBottomSheet(const _CategoryPickerSheet(), context);
  }

  void _openTeamSheet(BuildContext context) {
    showCustomBottomSheet(const _AddTeamMemberSheet(), context);
  }

  void _openExpenseSheet(BuildContext context, {Expense? existing, int? index}) {
    showCustomBottomSheet(
      _ExpenseInputSheet(existing: existing, index: index),
      context,
    );
  }

  void _openOffersSheet(BuildContext context) {
    showCustomBottomSheet(const _OffersSheet(), context);
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool isStart,
    required CampaignProvider provider,
  }) async {
    final initial = isStart
        ? (provider.startDate ?? DateTime.now())
        : (provider.endDate ?? provider.startDate ?? DateTime.now());
    final minimum = isStart
        ? DateTime.now().subtract(const Duration(days: 1))
        : (provider.startDate ?? DateTime.now());
    DateTime tempDate = initial;
    await showCustomBottomSheet(
      CupertinoDatePickerSheet(
        initialDate: initial,
        minimumDate: minimum,
        maximumDate: DateTime.now().add(const Duration(days: 365 * 3)),
        onDateChanged: (d) => tempDate = d,
      ),
      context,
    );
    if (isStart) {
      provider.setStartDate(tempDate);
    } else {
      provider.setEndDate(tempDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampaignProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 22,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create Campaign',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Details',
              style: txStyle16.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(4),
            Text(
              'Tell donors what you’re raising for and why',
              style: txStyle12.copyWith(color: Colors.grey[600]),
            ),
            const Gap(20),

            CustomTextField(
              labelText: 'Title',
              hintText: 'Give your campaign a name',
              isRequired: true,
              controller: provider.titleController,
              maxLength: 80,
              onChanged: (_) => provider.notifyListeners(),
            ),
            const Gap(14),

            CustomTextField(
              labelText: 'Description',
              hintText: 'Why are you running this campaign?',
              isRequired: true,
              controller: provider.descriptionController,
              maxLines: 4,
              onChanged: (_) => provider.notifyListeners(),
            ),
            const Gap(14),

            _SectionLabel(label: 'Category', isRequired: true),
            const Gap(6),
            _CategorySelectorTile(
              category: provider.selectedCategory,
              onTap: () => _openCategorySheet(context),
              onClear: provider.clearCategory,
            ),
            const Gap(14),

            CustomTextField(
              labelText: 'Fundraising Target',
              hintText: '0.00',
              prefix: '₦',
              isRequired: true,
              controller: provider.amountController,
              formatters: MoneyInputFormatter(),
              textInputType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => provider.notifyListeners(),
            ),
            const Gap(14),

            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    value: provider.startDate != null
                        ? provider.startDateController.text
                        : null,
                    hint: 'Select start',
                    onTap: () => _pickDate(
                      context,
                      isStart: true,
                      provider: provider,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _DateField(
                    label: 'End Date',
                    value: provider.endDate != null
                        ? provider.endDateController.text
                        : null,
                    hint: 'Select end',
                    onTap: () => _pickDate(
                      context,
                      isStart: false,
                      provider: provider,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(14),

            _SectionLabel(label: 'Campaign Images', isRequired: true),
            const Gap(2),
            Text(
              'Add up to ${CampaignProvider.maxImages} clear photos that tell your story.',
              style: txStyle12.copyWith(color: Colors.grey[600]),
            ),
            const Gap(8),
            _ImagesPicker(
              provider: provider,
              onPick: () => _pickImages(provider),
            ),
            const Gap(18),

            _SectionLabel(label: 'Team Members'),
            const Gap(6),
            _TeamSelector(
              provider: provider,
              onTap: () => _openTeamSheet(context),
            ),
            const Gap(18),

            _SectionLabel(label: 'Offers & Rewards'),
            const Gap(2),
            Text(
              'Optional perks for your donors',
              style: txStyle12.copyWith(color: Colors.grey[600]),
            ),
            const Gap(8),
            _OffersTile(
              count: provider.offersCount,
              onTap: () => _openOffersSheet(context),
            ),
            const Gap(18),

            _SectionLabel(label: 'Budget Breakdown'),
            const Gap(6),
            _BudgetSection(
              provider: provider,
              onAdd: () => _openExpenseSheet(context),
              onEdit: (i) => _openExpenseSheet(
                context,
                existing: provider.expenses[i],
                index: i,
              ),
            ),
            const Gap(28),

            CustomButton(
              label: 'Continue to Review',
              enabled: provider.canProceedToReview,
              onTap: () {
                if (!provider.canProceedToReview) {
                  showErrorToast('Please complete all required fields');
                  return;
                }
                Get.to(
                  () => const ReviewCampaignScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            const Gap(40),
          ],
        ),
      ),
    );
  }
}

// ─── Date Field ───────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: txStyle13.copyWith(fontWeight: FontWeight.w600)),
            Text('*', style: txStyle13.copyWith(color: Colors.red))
                .paddingOnly(left: 2),
          ],
        ),
        const Gap(5),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    style: hasValue
                        ? txStyle14
                        : txStyle14.copyWith(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: appPrimaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  const _SectionLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: txStyle13.copyWith(fontWeight: FontWeight.w600)),
        if (isRequired)
          Text('*', style: txStyle13.copyWith(color: Colors.red))
              .paddingOnly(left: 2),
      ],
    );
  }
}

// ─── Category Selector ────────────────────────────────────────────
class _CategorySelectorTile extends StatelessWidget {
  final Map<String, String>? category;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _CategorySelectorTile({
    required this.category,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final selected = category != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? appPrimaryColor : borderColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: appPrimaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Image.asset(
                      category!['icon'] ?? '',
                      width: 22,
                      height: 22,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.category_outlined,
                        color: appPrimaryColor,
                        size: 18,
                      ),
                    )
                  : const Icon(
                      Icons.category_outlined,
                      color: appPrimaryColor,
                      size: 18,
                    ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                selected ? category!['label']! : 'Select Category',
                style: txStyle14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
            if (selected)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampaignProvider>(context);
    return SizedBox(
      height: SizeConfig.heightOf(75),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/bottom_sheet_cureve_right.png'),
          Expanded(
            child: Container(
              color: const Color(0xffF1F1F7),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthOf(5),
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pick a Category',
                          style: txStyle16.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: borderColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      'Choose what best describes your fundraiser',
                      style: txStyle12.copyWith(color: Colors.grey[600]),
                    ),
                    const Gap(16),
                    Expanded(
                      child: ResponsiveState(
                        state: provider.categoriesState,
                        busyWidget: const UiBusyWidget(),
                        errorWidget: UiErrorWidget(
                          onRetry: () =>
                              provider.fetchCategories(force: true),
                        ),
                        noDataAvailableWidget: UiNoDataAvailableWidget(
                          height: SizeConfig.heightOf(40),
                          message: 'No categories available',
                        ),
                        successWidget: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: provider.categories.length,
                          itemBuilder: (context, index) {
                            final cat = provider.categories[index];
                            final isSelected =
                                provider.selectedCategory?['id'] == cat['id'];
                            return GestureDetector(
                              onTap: () {
                                provider.setCategory(cat);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? appPrimaryColor
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: appPrimaryColor.withValues(
                                          alpha: 0.10,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        cat['icon'] ?? '',
                                        width: 28,
                                        height: 28,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.category_outlined,
                                              color: appPrimaryColor,
                                            ),
                                      ),
                                    ),
                                    const Gap(8),
                                    Text(
                                      cat['label'] ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: txStyle12.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
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
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Multi-Image Picker ───────────────────────────────────────────
class _ImagesPicker extends StatelessWidget {
  final CampaignProvider provider;
  final VoidCallback onPick;

  const _ImagesPicker({required this.provider, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final images = provider.selectedImages;
    if (images.isEmpty) {
      return GestureDetector(
        onTap: onPick,
        child: DottedBorder(
          color: appPrimaryColor,
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
          radius: const Radius.circular(12),
          borderPadding: const EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 38,
                color: appPrimaryColor,
              ),
              const Gap(8),
              Text(
                'Add Campaign Images',
                style: txStyle13.copyWith(
                  fontWeight: FontWeight.w600,
                  color: appPrimaryColor,
                ),
              ),
              const Gap(4),
              Text(
                'Tap to choose from gallery',
                style: txStyle12.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final canAddMore = images.length < CampaignProvider.maxImages;
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: canAddMore ? images.length + 1 : images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return GestureDetector(
              onTap: onPick,
              child: DottedBorder(
                color: appPrimaryColor,
                strokeWidth: 1.5,
                dashPattern: const [6, 4],
                radius: const Radius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appPrimaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: appPrimaryColor,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 12,
                          color: appPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  images[index],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => provider.removeImage(index),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.75),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Team Selector (split-bill style) ─────────────────────────────
class _TeamSelector extends StatelessWidget {
  final CampaignProvider provider;
  final VoidCallback onTap;

  const _TeamSelector({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = provider.selectedTeamMembers;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: appPrimaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appPrimaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_add_outlined,
                color: appPrimaryColor,
                size: 20,
              ),
            ),
            const Gap(12),
            if (selected.isEmpty)
              Expanded(
                child: Text(
                  'Add team members (optional)',
                  style: txStyle13.copyWith(color: Colors.grey[700]),
                ),
              )
            else
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double avatarSize = 40;
                      const double step = avatarSize * 0.7;
                      final maxFit = constraints.maxWidth.isFinite
                          ? ((constraints.maxWidth - avatarSize) / step)
                                    .floor() +
                                1
                          : selected.length;
                      final maxVisible = maxFit.clamp(1, selected.length);
                      final showOverflow = selected.length > maxVisible;
                      final visibleCount =
                          showOverflow ? maxVisible - 1 : maxVisible;
                      final overflowCount = selected.length - visibleCount;

                      final tiles = <Widget>[];
                      for (int i = 0; i < visibleCount; i++) {
                        final p = selected[i];
                        final hasImage = p.imageUrl.isNotEmpty;
                        tiles.add(
                          Positioned(
                            left: i * step,
                            child: Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                image: hasImage
                                    ? DecorationImage(
                                        image: NetworkImage(p.imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: hasImage
                                  ? null
                                  : Text(
                                      (p.name.isNotEmpty
                                              ? p.name[0]
                                              : '?')
                                          .toUpperCase(),
                                      style: txStyle13.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: appPrimaryColor,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      }
                      if (showOverflow) {
                        tiles.add(
                          Positioned(
                            left: visibleCount * step,
                            child: Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appPrimaryColor.withValues(
                                  alpha: 0.12,
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+$overflowCount',
                                style: txStyle12.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: appPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Stack(
                        clipBehavior: Clip.hardEdge,
                        children: tiles.reversed.toList(),
                      );
                    },
                  ),
                ),
              ),
            const Gap(10),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _AddTeamMemberSheet extends StatelessWidget {
  const _AddTeamMemberSheet();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampaignProvider>(context);
    return SizedBox(
      height: SizeConfig.heightOf(85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/bottom_sheet_cureve_right.png'),
          Expanded(
            child: Container(
              color: const Color(0xffF1F1F7),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthOf(5),
                  vertical: 16,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Team Members',
                            style: txStyle16.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: borderColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      CustomSearchField(
                        textEditingController: provider.teamSearchController,
                        hintText: 'Search by name or username',
                        onChange: provider.filterTeamMembers,
                      ),
                      if (provider.selectedTeamMembers.isNotEmpty) ...[
                        const Gap(14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Added (${provider.selectedTeamMembers.length})',
                            style: txStyle13.copyWith(
                              fontWeight: FontWeight.w600,
                              color: appPrimaryColor,
                            ),
                          ),
                        ),
                        const Gap(8),
                        SizedBox(
                          height: 56,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.selectedTeamMembers.length,
                            separatorBuilder: (_, __) => const Gap(8),
                            itemBuilder: (context, i) {
                              final p = provider.selectedTeamMembers[i];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: appPrimaryColor,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _Avatar(participant: p, size: 32),
                                    const Gap(6),
                                    Text(
                                      p.name,
                                      style: txStyle12.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Gap(6),
                                    GestureDetector(
                                      onTap: () =>
                                          provider.removeTeamMember(p.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(
                                            alpha: 0.10,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const Gap(14),
                      Expanded(
                        child: ResponsiveState(
                          state: provider.usersState,
                          busyWidget: const UiBusyWidget(),
                          errorWidget: UiErrorWidget(
                            onRetry: () => provider.fetchUsers(force: true),
                          ),
                          noDataAvailableWidget: UiNoDataAvailableWidget(
                            height: SizeConfig.heightOf(40),
                            message: 'No users found',
                          ),
                          successWidget: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: provider.filteredUsers.length,
                            separatorBuilder: (_, __) => const Gap(8),
                            itemBuilder: (context, i) {
                              final p = provider.filteredUsers[i];
                              final selected = provider.isTeamMemberSelected(
                                p.id,
                              );
                              return InkWell(
                                onTap: () => provider.toggleTeamMember(p),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? appPrimaryColor
                                          : Colors.transparent,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _Avatar(participant: p, size: 38),
                                      const Gap(10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name.isEmpty
                                                  ? p.username
                                                  : p.name,
                                              style: txStyle13.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (p.username.isNotEmpty)
                                              Text(
                                                '@${p.username}',
                                                style: txStyle12.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? appPrimaryColor
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: selected
                                                ? appPrimaryColor
                                                : Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: selected
                                            ? const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const Gap(8),
                      CustomButton(
                        label:
                            'Done${provider.selectedTeamMembers.isEmpty ? '' : ' (${provider.selectedTeamMembers.length})'}',
                        onTap: () => Navigator.pop(context),
                      ),
                      const Gap(8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Participant participant;
  final double size;
  const _Avatar({required this.participant, required this.size});

  @override
  Widget build(BuildContext context) {
    if (participant.imageUrl.isNotEmpty) {
      return CustomNetworkImage(
        imageUrl: participant.imageUrl,
        radius: size,
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appPrimaryColor.withValues(alpha: 0.15),
      ),
      alignment: Alignment.center,
      child: Text(
        (participant.name.isNotEmpty ? participant.name[0] : '?').toUpperCase(),
        style: txStyle13.copyWith(
          fontWeight: FontWeight.bold,
          color: appPrimaryColor,
        ),
      ),
    );
  }
}

// ─── Budget / Expenses ────────────────────────────────────────────
class _BudgetSection extends StatelessWidget {
  final CampaignProvider provider;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;

  const _BudgetSection({
    required this.provider,
    required this.onAdd,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...provider.expenses.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: appPrimaryColor,
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₦${e.cost.toStringAsFixed(2)}',
                        style: txStyle12.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onEdit(i),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: appPrimaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => provider.removeExpense(i),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: appSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }),
        GestureDetector(
          onTap: onAdd,
          child: DottedBorder(
            color: appPrimaryColor,
            strokeWidth: 1.2,
            dashPattern: const [6, 4],
            radius: const Radius.circular(10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: appPrimaryColor,
                  size: 18,
                ),
                const Gap(8),
                Text(
                  provider.expenses.isEmpty
                      ? 'Add a budget item'
                      : 'Add another item',
                  style: txStyle13.copyWith(
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (provider.expenses.isNotEmpty) ...[
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total: ₦${provider.totalExpenses.toStringAsFixed(2)}',
                style: txStyle13.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ExpenseInputSheet extends StatefulWidget {
  final Expense? existing;
  final int? index;
  const _ExpenseInputSheet({this.existing, this.index});

  @override
  State<_ExpenseInputSheet> createState() => _ExpenseInputSheetState();
}

class _ExpenseInputSheetState extends State<_ExpenseInputSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _costCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _costCtrl = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.cost.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampaignProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Gap(16),
            Text(
              widget.existing == null ? 'Add Budget Item' : 'Edit Budget Item',
              style: txStyle16.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(14),
            CustomTextField(
              labelText: 'Item Name',
              hintText: 'e.g. Studio rental',
              controller: _nameCtrl,
              isRequired: true,
            ),
            const Gap(12),
            CustomTextField(
              labelText: 'Estimated Cost',
              hintText: '0.00',
              prefix: '₦',
              controller: _costCtrl,
              formatters: MoneyInputFormatter(),
              textInputType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              isRequired: true,
            ),
            const Gap(20),
            CustomButton(
              label: widget.existing == null ? 'Add' : 'Save',
              onTap: () {
                final name = _nameCtrl.text.trim();
                final cost =
                    double.tryParse(_costCtrl.text.replaceAll(',', '')) ?? 0;
                if (name.isEmpty || cost <= 0) {
                  showErrorToast('Provide a name and a valid cost');
                  return;
                }
                final expense = Expense(name: name, cost: cost);
                if (widget.existing != null && widget.index != null) {
                  provider.updateExpense(widget.index!, expense);
                } else {
                  provider.addExpense(expense);
                }
                Navigator.pop(context);
              },
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}

// ─── Offers ───────────────────────────────────────────────────────
class _OffersTile extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _OffersTile({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasOffers = count > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: hasOffers ? appPrimaryColor : borderColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: appPrimaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.card_giftcard_outlined,
                color: appPrimaryColor,
                size: 18,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasOffers ? 'Edit Offers' : 'Add Offers',
                    style: txStyle14.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    hasOffers
                        ? '$count offer${count == 1 ? '' : 's'} added'
                        : 'Reward donors who hit milestones',
                    style: txStyle12.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _OffersSheet extends StatefulWidget {
  const _OffersSheet();

  @override
  State<_OffersSheet> createState() => _OffersSheetState();
}

class _OffersSheetState extends State<_OffersSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Working copies seeded from the provider so changes only commit on Save.
  late List<Map<String, String>> _auto;
  late List<Map<String, String>> _manual;

  final TextEditingController _conditionCtrl = TextEditingController();
  final TextEditingController _rewardCtrl = TextEditingController();
  int? _selectedPreset;

  static const List<Map<String, String>> _presets = [
    {
      'condition': 'Donate ₦500 or more',
      'reward': 'Thank you message',
    },
    {
      'condition': 'Donate ₦1,000 or more',
      'reward': 'Personal shoutout',
    },
    {
      'condition': 'Donate ₦2,500 or more',
      'reward': 'Social media mention',
    },
    {
      'condition': 'Donate ₦5,000 or more',
      'reward': 'Early access update',
    },
    {
      'condition': 'Donate ₦10,000 or more',
      'reward': 'Behind-the-scenes video',
    },
    {
      'condition': 'Donate ₦20,000 or more',
      'reward': 'Signed thank you card',
    },
    {
      'condition': 'Share campaign 5x',
      'reward': 'Bonus entry prize',
    },
    {
      'condition': 'Refer 3 donors',
      'reward': 'Special recognition',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    final provider = Provider.of<CampaignProvider>(context, listen: false);
    _auto = provider.autoOffers
        .map((m) => Map<String, String>.from(m))
        .toList();
    _manual = provider.manualOffers
        .map((m) => Map<String, String>.from(m))
        .toList();
  }

  @override
  void dispose() {
    _tab.dispose();
    _conditionCtrl.dispose();
    _rewardCtrl.dispose();
    super.dispose();
  }

  void _addAutoFromPreset() {
    if (_selectedPreset == null) return;
    final preset = _presets[_selectedPreset!];
    final exists = _auto.any(
      (o) =>
          o['condition'] == preset['condition'] &&
          o['reward'] == preset['reward'],
    );
    if (exists) {
      showErrorToast('Offer already added');
      return;
    }
    setState(() {
      _auto.add({
        'type': 'auto',
        'condition': preset['condition']!,
        'reward': preset['reward']!,
      });
      _selectedPreset = null;
    });
  }

  void _addManual() {
    final cond = _conditionCtrl.text.trim();
    final rew = _rewardCtrl.text.trim();
    if (cond.isEmpty || rew.isEmpty) {
      showErrorToast('Provide both a condition and a reward');
      return;
    }
    setState(() {
      _manual.add({'type': 'manual', 'condition': cond, 'reward': rew});
      _conditionCtrl.clear();
      _rewardCtrl.clear();
    });
  }

  void _save() {
    final provider = Provider.of<CampaignProvider>(context, listen: false);
    provider.setOffers(_auto, _manual);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.heightOf(85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/bottom_sheet_cureve_right.png'),
          Expanded(
            child: Container(
              color: const Color(0xffF1F1F7),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthOf(5),
                  vertical: 16,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Offers & Rewards',
                            style: txStyle16.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: borderColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        'Reward donors automatically or manually',
                        style: txStyle12.copyWith(color: Colors.grey[600]),
                      ),
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TabBar(
                          controller: _tab,
                          indicator: BoxDecoration(
                            color: appPrimaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey[700],
                          labelStyle: txStyle13.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: txStyle13.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Auto'),
                            Tab(text: 'Manual'),
                          ],
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: TabBarView(
                          controller: _tab,
                          children: [
                            _autoTab(),
                            _manualTab(),
                          ],
                        ),
                      ),
                      const Gap(8),
                      CustomButton(label: 'Save Offers', onTap: _save),
                      const Gap(4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _autoTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          'Pick a preset and we’ll verify it automatically.',
          style: txStyle12.copyWith(color: Colors.grey[700]),
        ),
        const Gap(10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedPreset,
              hint: Text(
                'Select a preset condition',
                style: txStyle13.copyWith(color: Colors.grey),
              ),
              items: _presets
                  .asMap()
                  .entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(
                        e.value['condition']!,
                        style: txStyle13,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedPreset = v),
            ),
          ),
        ),
        const Gap(10),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: 'Add Auto Offer',
            height: 42,
            onTap: _addAutoFromPreset,
            enabled: _selectedPreset != null,
          ),
        ),
        const Gap(14),
        if (_auto.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No auto offers yet',
              textAlign: TextAlign.center,
              style: txStyle13.copyWith(color: Colors.grey),
            ),
          )
        else
          ..._auto.asMap().entries.map(
                (e) => _offerCard(
                  e.value,
                  onRemove: () => setState(() => _auto.removeAt(e.key)),
                ),
              ),
      ],
    );
  }

  Widget _manualTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          'Add a custom condition you’ll verify yourself.',
          style: txStyle12.copyWith(color: Colors.grey[700]),
        ),
        const Gap(10),
        CustomTextField(
          labelText: 'Condition',
          hintText: 'e.g. Donate ₦5,000 and tag us',
          controller: _conditionCtrl,
        ),
        const Gap(10),
        CustomTextField(
          labelText: 'Reward',
          hintText: 'e.g. Free T-shirt',
          controller: _rewardCtrl,
        ),
        const Gap(10),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: 'Add Manual Offer',
            height: 42,
            onTap: _addManual,
          ),
        ),
        const Gap(14),
        if (_manual.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No manual offers yet',
              textAlign: TextAlign.center,
              style: txStyle13.copyWith(color: Colors.grey),
            ),
          )
        else
          ..._manual.asMap().entries.map(
                (e) => _offerCard(
                  e.value,
                  onRemove: () => setState(() => _manual.removeAt(e.key)),
                ),
              ),
      ],
    );
  }

  Widget _offerCard(
    Map<String, String> offer, {
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.card_giftcard_outlined,
            color: appPrimaryColor,
            size: 18,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer['condition'] ?? '',
                  style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                ),
                if ((offer['reward'] ?? '').isNotEmpty)
                  Text(
                    offer['reward']!,
                    style: txStyle12.copyWith(color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
