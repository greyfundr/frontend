import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';
import 'package:greyfundr/core/models/budget_model.dart';

import 'package:provider/provider.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';

import 'package:greyfundr/widgets/fundraisetarget/fundraising_target_section.dart';
import 'package:greyfundr/widgets/fundraisetarget/expense_section.dart';
import 'package:greyfundr/widgets/fundraisetarget/date_range_section.dart';
import 'package:greyfundr/widgets/fundraisetarget/image_upload_section.dart';
import 'package:greyfundr/widgets/fundraisetarget/team_section.dart';
import 'package:greyfundr/widgets/fundraisetarget/bottom_action_buttons.dart';

import 'package:greyfundr/bottomsheets/fundraisetarget/expense_bottom_sheet.dart';
import 'package:greyfundr/bottomsheets/fundraisetarget/customize_campaign_sheet.dart';
import 'package:greyfundr/bottomsheets/fundraisetarget/user_selection_sheet.dart';
import 'package:greyfundr/bottomsheets/fundraisetarget/add_team_member_sheet.dart';
import 'package:greyfundr/bottomsheets/fundraisetarget/thank_you_message_sheet.dart';

import 'package:greyfundr/features/campaign/createcampaignflow/create_campaign.dart';
import 'package:greyfundr/features/campaign/createcampaignflow/review_campaign.dart';

class FundraisingTargetScreen extends StatefulWidget {
  final Campaign campaign;
  const FundraisingTargetScreen({super.key, required this.campaign});

  @override
  State<FundraisingTargetScreen> createState() => _FundraisingTargetScreenState();
}

class _FundraisingTargetScreenState extends State<FundraisingTargetScreen> {
  // Controllers & State
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  List<File> selectedImages = [];
  List<Participant> selectedParticipants = [];
  List<Participant> allUsers = [];
  List<Expense> expenses = [];

  bool isFetchingUsers = false;
  String? usersError;

  // Using CampaignProvider for users and campaign actions

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // start loading users early
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    if (allUsers.isNotEmpty) return;

    if (!mounted) return;
    setState(() {
      isFetchingUsers = true;
      usersError = null;
    });

    try {
      final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
      final users = await campaignProvider.fetchUsers();

      if (!mounted) return;
      setState(() {
        allUsers = users;
        isFetchingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        usersError = e.toString().replaceAll('Exception: ', '');
        isFetchingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load team members: $usersError')),
      );
    }
  }

  // Callbacks
  void _onDateSelected(DateTime start, DateTime end) {
    setState(() {
      selectedStartDate = start;
      selectedEndDate = end;
      _startDateController.text = DateFormat('dd/MM/yyyy').format(start);
      _endDateController.text = DateFormat('dd/MM/yyyy').format(end);
    });
  }

  void _onImagesChanged(List<File> images) => setState(() => selectedImages = images);

  void _onParticipantsChanged(List<Participant> participants) =>
      setState(() => selectedParticipants = participants);

  void _onExpensesChanged(List<Expense> newExpenses) => setState(() => expenses = newExpenses);

  void _validateAndProceed() {
    // 1. Amount
    final cleanStr = _amountController.text.replaceAll(',', '').trim();
    if (cleanStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a fundraising target')),
      );
      return;
    }

    final double? targetAmount = double.tryParse(cleanStr);
    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target must be a valid number greater than zero')),
      );
      return;
    }

    // 2. Dates
    if (selectedStartDate == null || selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    if (selectedEndDate!.isBefore(selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date')),
      );
      return;
    }

    // 3. Images
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image')),
      );
      return;
    }

    // Save to campaign model
    widget.campaign.setCampaignDetails(
      DateFormat('dd/MM/yyyy').format(selectedStartDate!),
      DateFormat('dd/MM/yyyy').format(selectedEndDate!),
      selectedImages[0],
      targetAmount,
      selectedParticipants,
      selectedImages,
      expenses,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewCampaignScreen(campaign: widget.campaign),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Start Campaign'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CampaignScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FundraisingTargetSection(controller: _amountController),
            ExpenseSection(
              expenses: expenses,
              onAddPressed: () => _openExpenseSheet(),
            ),
            DateRangeSection(
              startDate: selectedStartDate,
              endDate: selectedEndDate,
              onDateRangeSelected: _onDateSelected,
            ),
            ImageUploadSection(
              selectedImages: selectedImages,
              onImagesChanged: _onImagesChanged,
              imagePicker: _imagePicker,
            ),
            const SizedBox(height: 24),

            // ── Team / Users Section ───────────────────────────────
            if (isFetchingUsers)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (usersError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      'Failed to load team members\n$usersError',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _fetchUsers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (allUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No team members available')),
              )
            else
              TeamSection(
                selectedParticipants: selectedParticipants,
                allUsers: allUsers,
                onParticipantsChanged: _onParticipantsChanged,
                onAddPressed: () => _showAddTeamMemberSheet(),
              ),

            const SizedBox(height: 32),

            BottomActionButtons(
              onCustomize: _showCustomizeSheet,
              onProceed: _validateAndProceed,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _openExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseBottomSheet(
        expenses: expenses,
        onExpensesChanged: _onExpensesChanged,
      ),
    );
  }

  void _showCustomizeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CustomizeCampaignSheet(
        onThankYouPressed: () => _showThankYouSheet(),
      ),
    );
  }

  void _showAddTeamMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddTeamMemberSheet(
        onSelectMembersPressed: () => _showUserSelectionSheet(),
      ),
    );
  }

  void _showUserSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserSelectionSheet(
        allUsers: allUsers,
        initiallySelected: selectedParticipants,
        onSelectionConfirmed: (selected) {
          setState(() => selectedParticipants = selected);
        },
      ),
    );
  }

  void _showThankYouSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const ThankYouMessageSheet(),
    );
  }
}