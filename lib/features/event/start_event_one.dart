import 'package:flutter/material.dart';

import 'package:greyfundr/features/campaign/createcampaignflow/fundraise_target.dart';
import 'package:greyfundr/features/home/home_screen.dart';
import 'package:greyfundr/core/models/campaign_model.dart';

import 'package:greyfundr/components/event/personal_account_card.dart';
import 'package:greyfundr/components/event/event_title_field.dart';
import 'package:greyfundr/components/event/event_description_field.dart';
import 'package:greyfundr/components/event/next_button.dart';

import 'package:greyfundr/widgets/campaignforyou/category_picker.dart';
import 'package:greyfundr/widgets/campaignforyou/offers_bottom_sheet.dart';
import 'package:greyfundr/widgets/campaignforyou/selected_category_chip.dart';
import 'package:greyfundr/widgets/campaignforyou/offer_item_tile.dart';


class StartEventOne extends StatefulWidget {
  const StartEventOne({super.key});

  @override
  State<StartEventOne> createState() => _StartEventOneState();
}

class _StartEventOneState extends State<StartEventOne> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? selectedCategory;
  List<Map<String, String>> autoOffers = [];
  List<Map<String, String>> manualOffers = [];

  bool get hasOffers => autoOffers.isNotEmpty || manualOffers.isNotEmpty;
  bool get canProceed =>
      _titleCtrl.text.trim().isNotEmpty &&
      _descCtrl.text.trim().isNotEmpty &&
      selectedCategory != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    final campaign = Campaign(
      _titleCtrl.text.trim(),
      _descCtrl.text.trim(),
      selectedCategory!,
      manualOffers,
      autoOffers,
    );

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FundraisingTargetScreen(campaign: campaign),
        transitionDuration: Duration.zero,
      ),
      (_) => false,
    );
  }

  void _removeOffer(bool isAuto, int index) {
    setState(() {
      isAuto ? autoOffers.removeAt(index) : manualOffers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        foregroundColor: Colors.black,
        elevation: 1, // No shadow under app bar
        title: const Text('Start Event'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Try to pop; if there's no previous route, go to Home
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PersonalAccountCard(),
            const SizedBox(height: 16),

            CampaignTitleField(controller: _titleCtrl),
            const SizedBox(height: 16),

            EventDescriptionField(controller: _descCtrl),
            const SizedBox(height: 18),

            // Category
            selectedCategory == null
                ? _optionTile(
               icon: Icons.add_circle, // <-- changed to add icon
               title: 'Select Category',
               subtitle: 'What kind of event are you creating?',
               onTap: () => showCategoryPicker(context)
               .then((cat) => setState(() => selectedCategory = cat)),
                )
                : SelectedCategoryChip(
                    category: selectedCategory!,
                    onRemove: () => setState(() => selectedCategory = null),
                  ),

            const SizedBox(height: 10),

            // Offers
            _optionTile(
             icon: Icons.add_circle, 
              title: hasOffers ? 'Edit Offers & Rewards' : 'Set Offers with Rewards',
              subtitle: hasOffers ? '${autoOffers.length + manualOffers.length} offer(s) added' : 'Optional: Give perks to donors',
              onTap: () => showOffersBottomSheet(
                context,
                onSave: (auto, manual) => setState(() {
                  autoOffers = auto;
                  manualOffers = manual;
                }),
              ),
            ),

            if (hasOffers) ...[
              const SizedBox(height: 16),
              if (autoOffers.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8),
                  child: Text('Auto Offers', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ...autoOffers.asMap().entries.map((e) => OfferItemTile(
                    offer: e.value,
                    isAuto: true,
                    index: e.key,
                    onDelete: () => _removeOffer(true, e.key),
                  )),

              if (manualOffers.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 16, bottom: 8),
                  child: Text('Manual Offers', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ...manualOffers.asMap().entries.map((e) => OfferItemTile(
                    offer: e.value,
                    isAuto: false,
                    index: e.key,
                    onDelete: () => _removeOffer(false, e.key),
                  )),
            ],

            const SizedBox(height: 20),
            NextButton(enabled: canProceed, onPressed: _goNext),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00A9A5), size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      
    );
  }
}