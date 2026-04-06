import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/components/custom_media_picker.dart';
import 'package:greyfundr/components/custom_time_picker_textField.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';

class Step5FinancingAndActivities extends StatelessWidget {
  const Step5FinancingAndActivities({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Financing & Activities",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Manage tickets, gifts, and set event highlights",
            style: txStyle14.copyWith(color: Colors.grey[600]),
          ),
          Gap(20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Accept Gift?", style: txStyle15),
              Switch(
                value: provider.acceptDonations,
                activeThumbColor: appPrimaryColor,
                onChanged: provider.toggleAcceptDonations,
              ),
            ],
          ),
          const Gap(20),

          if (provider.acceptDonations) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hide Donation Amount?", style: txStyle15),
                Switch(
                  value: provider.hideDonationAmount,
                  activeThumbColor: appPrimaryColor,
                  onChanged: provider.toggleHideDonationAmount,
                ),
              ],
            ),
            const Gap(12),
            CustomTextField(
              labelText: "Target Gift Amount",
              hintText: "~10,000,000",
              controller: provider.targetAmountCtrl,
              textInputType: TextInputType.number,
              formatters: MoneyInputFormatter(),
            ),
            const Gap(16),
          ],

          CustomTextField(
            labelText: "Expected Number of Participants",
            hintText: "e.g. 100",
            controller: provider.expectedParticipantsCtrl,
            textInputType: TextInputType.number,
            onChanged: (_) => provider.notifyListeners(),
          ),
          const Gap(10),

          Divider(color: borderColor, height: 0),
          const Gap(10),

          // Purchasable Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Purchasable Items (Merch and Gifts)",
                style: txStyle15.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: appPrimaryColor),
                onPressed: () =>
                    _showAddPurchasableItemDialog(context, provider),
              ),
            ],
          ),

          if (provider.purchasableItems.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.purchasableItems.length,
              itemBuilder: (context, index) {
                final item = provider.purchasableItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: item.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(item.images.first.path),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : item.existingImageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.existingImageUrls.first,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.shopping_bag_outlined, size: 40),
                  title: Text(
                    item.name,
                    style: txStyle14.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${convertStringToCurrency(item.price.toString())} • Qty: ${item.quantity}",
                    style: txStyle13,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => provider.removePurchasableItem(index),
                  ),
                );
              },
            ),
          const Gap(10),

          const Divider(color: borderColor, height: 0),
          const Gap(10),

          // Activities
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Event Activities",
                style: txStyle15.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: appPrimaryColor),
                onPressed: () => _showAddActivityDialog(context, provider),
              ),
            ],
          ),
          Text(
            "Note: Activities can be edited later. Activities will be pinned to the big screen at their scheduled time.",
            style: txStyle12.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Gap(16),

          if (provider.activities.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.activities.length,
              itemBuilder: (context, index) {
                final act = provider.activities[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: act.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(act.image!.path),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : (act.existingImageUrl?.isNotEmpty ?? false)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            act.existingImageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.event_note, size: 40),
                  title: Text(
                    act.name,
                    style: txStyle14.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${formatDateToTime(DateTime.parse(act.time))}\nGoal: ${convertStringToCurrency(act.targetAmount.toString())}",
                    style: txStyle13,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => provider.removeActivity(index),
                  ),
                );
              },
            ),

          // const Gap(100),
        ],
      ),
    );
  }

  void _showAddPurchasableItemDialog(
    BuildContext context,
    EventProvider provider,
  ) {
    showCustomBottomSheet(
      _AddPurchasableItemSheet(provider: provider),
      context,
      backgroundColor: Colors.transparent,
    );
  }

  void _showAddActivityDialog(BuildContext context, EventProvider provider) {
    showCustomBottomSheet(
      _AddActivitySheet(provider: provider),
      context,
      backgroundColor: Colors.transparent,
    );
  }
}

class _AddPurchasableItemSheet extends StatefulWidget {
  final EventProvider provider;
  const _AddPurchasableItemSheet({required this.provider});

  @override
  State<_AddPurchasableItemSheet> createState() =>
      _AddPurchasableItemSheetState();
}

class _AddPurchasableItemSheetState extends State<_AddPurchasableItemSheet> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  List<XFile> images = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/bottom_sheet_cureve_right.png"),
        Container(
          color: Color(0xffF1F1F7),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Item",
                    style: txStyle16.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Gap(16),
                  CustomTextField(labelText: "Name", controller: nameCtrl),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          labelText: "Price",
                          controller: priceCtrl,
                          textInputType: TextInputType.number,
                          formatters: MoneyInputFormatter(),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: CustomTextField(
                          labelText: "Quantity",
                          controller: qtyCtrl,
                          textInputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Text(
                    "Item Images",
                    style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Gap(8),
                  CustomMediaPicker(
                    images: images,
                    onAddMedia: () async {
                      final picked = await ImagePicker().pickMultiImage();
                      if (picked.isNotEmpty) {
                        setState(() => images.addAll(picked));
                      }
                    },
                    onRemoveMedia: (index) {
                      setState(() => images.removeAt(index));
                    },
                  ),
                  const Gap(24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.isNotEmpty) {
                          // Money formatter adds commas, so we need to clean it up before parsing
                          final rawPrice = priceCtrl.text.replaceAll(',', '');
                          widget.provider.addPurchasableItem(
                            PurchasableItem(
                              name: nameCtrl.text,
                              price: double.tryParse(rawPrice) ?? 0,
                              quantity: int.tryParse(qtyCtrl.text) ?? 0,
                              images: images,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "SAVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddActivitySheet extends StatefulWidget {
  final EventProvider provider;
  const _AddActivitySheet({required this.provider});

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  XFile? image;
  DateTime? selectedTime;
  bool setTargetAmount = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/bottom_sheet_cureve_right.png"),
        Container(
          color: Color(0xffF1F1F7),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Activity",
                  style: txStyle16.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(16),
                CustomTextField(
                  labelText: "Activity Name",
                  controller: nameCtrl,
                ),
                const Gap(12),
                CustomTextField(labelText: "Description", controller: descCtrl),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Set Target Amount", style: txStyle15),
                    Switch(
                      value: setTargetAmount,
                      activeThumbColor: appPrimaryColor,
                      onChanged: (value) {
                        setState(() {
                          setTargetAmount = value;
                          if (!setTargetAmount) {
                            amountCtrl.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  children: [
                    if (setTargetAmount) ...[
                      Expanded(
                        child: CustomTextField(
                          labelText: "Target Amount",
                          controller: amountCtrl,
                          textInputType: TextInputType.number,
                          formatters: MoneyInputFormatter(),
                        ),
                      ),
                      const Gap(12),
                    ],
                    Expanded(
                      child: CustomTimePickerTextFiled(
                        labelText: "Time",
                        selectedTime: selectedTime?.toIso8601String() ?? "",
                        onTimeChanged: (t) {
                          setState(() => selectedTime = t);
                        },
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Text(
                  "Activity Image",
                  style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                ),
                const Gap(8),
                CustomMediaPicker(
                  images: image != null ? [image!] : [],
                  onAddMedia: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      setState(() => image = picked);
                    }
                  },
                  onRemoveMedia: (index) {
                    setState(() => image = null);
                  },
                ),
                const Gap(24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty) {
                        final rawAmount = amountCtrl.text.replaceAll(',', '');
                        widget.provider.addActivity(
                          EventActivity(
                            name: nameCtrl.text,
                            description: descCtrl.text,
                            targetAmount: setTargetAmount
                                ? (double.tryParse(rawAmount) ?? 0)
                                : 0,
                            time: selectedTime?.toIso8601String() ?? "TBD",
                            image: image,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "SAVE ACTIVITY",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
