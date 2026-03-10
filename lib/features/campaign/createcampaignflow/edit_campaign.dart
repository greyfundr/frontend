// lib/screens/campaign/edit_campaign_screen.dart
import 'package:flutter/material.dart';

import 'package:greyfundr/core/models/budget_model.dart';
import 'package:greyfundr/core/models/campaign_model.dart';

import 'package:greyfundr/widgets/editcampaign/edit_campaign_header.dart';
import 'package:greyfundr/widgets/editcampaign/edit_campaign_progress.dart';

import 'package:greyfundr/widgets/editcampaign/participants_section.dart';
import 'package:greyfundr/widgets/editcampaign/campaign_tabs.dart';

import 'package:greyfundr/modals/image_manager_modal.dart';
import 'package:greyfundr/modals/edit_title_bottomsheet.dart';
import 'package:greyfundr/modals/edit_about_modal.dart';
import 'package:greyfundr/modals/edit_budget_modal.dart';
import 'package:greyfundr/modals/edit_offers_modal.dart';
import 'package:greyfundr/modals/edit_participants_modal.dart';

class EditCampaignScreen extends StatefulWidget {
  final Campaign campaign;
  const EditCampaignScreen({super.key, required this.campaign});

  @override
  State<EditCampaignScreen> createState() => _EditCampaignScreenState();
}

class _EditCampaignScreenState extends State<EditCampaignScreen> {
  late Campaign _campaign;
  late String _description;
  late List<Expense> _budget;
  late List<Map<String, String>> _offers;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _campaign = Campaign.from(widget.campaign);
    _description = _campaign.description;
    _budget = List.from(widget.campaign.budgets);
    _offers = [
      ..._campaign.savedAutoOffers,
      ..._campaign.savedManualOffers,
    ];
  }

  void _saveAndExit() {
    _campaign.description = _description;
    _campaign.budgets = _budget;
    _campaign.savedAutoOffers = _offers.where((o) => o['type'] == 'auto').toList();
    _campaign.savedManualOffers = _offers.where((o) => o['type'] != 'auto').toList();

    Navigator.pop(context, _campaign);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          
          EditCampaignHeader(
            images: _campaign.images,
            onEditPressed: () => showImageManagerModal(
              context,
              _campaign.images,
              (newImages) => setState(() => _campaign.images = newImages),
            ),
          ),

          
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _campaign.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.teal),
                        onPressed: () => showEditTitleBottomSheet(
  context,
  _campaign.title,
  (newTitle) => setState(() => _campaign.title = newTitle),
),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    EditCampaignProgress(campaign: widget.campaign),
                    const SizedBox(height: 6),

                    ParticipantsSection(
                      participants: _campaign.participants,
                      onEdit: () => showEditParticipantsModal(
                        context,
                        _campaign.participants,
                        (updated) => setState(() => _campaign.participants = updated),
                      ),
                    ),
                    const SizedBox(height: 10),

                    CampaignTabs(
                      selectedIndex: _selectedTab,
                      onTabChanged: (i) => setState(() => _selectedTab = i),
                      description: _description,
                      budgetItems: _budget,
                      offers: _offers,
                      onEditAbout: () => showEditAboutModal(context, _description, (d) => setState(() => _description = d)),
                      onEditBudget: () => showEditBudgetModal(context, _budget, (b) => setState(() => _budget = b)),
                      onEditOffers: () => showEditOffersModal(context, _offers, (o) => setState(() => _offers = o)),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 55), 
          child: ElevatedButton(
            onPressed: _saveAndExit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(0, 164, 175, 1),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 8,
            ),
            child: Text(
              "FINISHED EDITING!",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}