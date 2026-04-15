import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/dependencies/locator.dart';
import 'package:greyfundr/core/models/all_user_model.dart';
import 'package:greyfundr/core/models/my_split_bill_model.dart';
import 'package:greyfundr/core/models/split_bill_details_model.dart';
import 'package:greyfundr/core/models/split_bill_invite_model.dart';
import 'package:greyfundr/core/models/split_bill_response_model.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_success_screen.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/utils.dart';

class NewSplitBillProvider extends BaseNotifier {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var totalAmountController = TextEditingController();
  File? receiptFile;
  File? billImageFile;
  String? receiptUrl;
  String? billImageUrl;
  DateTime? dueDate;
  bool allowPartialPayments = false;
  TextEditingController minPaymentAmountForPartial = TextEditingController();
  String splitMethod = 'EVEN';
  bool isSplitBillFormComplete = false;
  var newSplitBillTitleController = TextEditingController();
  final splitBillApi = locator<SplitBillApi>();
  bool isAmountEqual = false;

  // Participants management - stores map of id -> participant type
  Map<String, dynamic> selectedParticipantsMap = {};
  var searchParticipantController = TextEditingController();

  // check if all participant amount is equal
  void checkIfAmountsAreEqual() {
    final participants = getSelectedParticipants();
    if (participants.isEmpty) {
      isAmountEqual = false;
      notifyListeners();
      return;
    }

    final firstAmount =
        participants[0].amountController?.text.replaceAll(',', '') ?? '0';
    isAmountEqual = participants.every(
      (participant) =>
          participant.amountController?.text.replaceAll(',', '') == firstAmount,
    );
    notifyListeners();
  }

  // ==========================
  // EDIT SPLIT BILL VARIABLES
  // ==========================
  var editTitleController = TextEditingController();
  var editDescriptionController = TextEditingController();
  var editTotalAmountController = TextEditingController();
  File? editReceiptFile;
  File? editBillImageFile;
  String? editReceiptUrl;
  String? editBillImageUrl;
  DateTime? editDueDate;
  bool editAllowPartialPayments = false;
  TextEditingController editMinPaymentAmountForPartial =
      TextEditingController();
  String editSplitMethod = 'EVEN';
  bool isEditSplitBillFormComplete = true;
  bool isEditAmountEqual = false;

  Map<String, dynamic> editSelectedParticipantsMap = {};

  void initEditSplitBill(SplitBillDetailsModel details) {
    var data = details.data;
    if (data == null) return;

    editTitleController.text = data.title ?? '';
    editDescriptionController.text = data.description ?? '';
    editTotalAmountController.text = (data.totalAmount ?? 0).toString();
    editDueDate = data.dueDate;
    editAllowPartialPayments = data.allowPartialPayment ?? false;
    editMinPaymentAmountForPartial.text = (data.minPaymentAmount ?? 0)
        .toString();
    editSplitMethod = data.splitMethod ?? 'EVEN';

    editReceiptUrl = data.billReceipt;
    editBillImageUrl = data.imageUrl;

    editSelectedParticipantsMap.clear();

    if (data.participants != null) {
      for (var p in data.participants!) {
        var participant = CustomParticipantClass(
          type: (p.userId != null) ? "USER" : "GUEST",
          id:
              p.userId ??
              p.id ??
              '', // Using userId if available, else participant id
          name: (p.userId != null)
              ? ("${p.user?.firstName} ${p.user?.lastName}")
              : (p.guestName ?? 'Guest'),
          phoneNumber: (p.userId != null)
              ? "${p.user?.phoneNumber}"
              : p.guestPhone ?? '',
        );

        participant.amountController = TextEditingController(
          text: (p.amountOwed ?? 0).toString(),
        );
        participant.percentageController = TextEditingController(
          text: p.percentage?.toString() ?? '0',
        );

        editSelectedParticipantsMap[participant.id] = participant;
      }
    }

    checkIfEditAmountsAreEqual();
    notifyListeners();
  }

  void disposeEditSplitBill() {
    editTitleController.clear();
    editDescriptionController.clear();
    editTotalAmountController.clear();
    editMinPaymentAmountForPartial.clear();
    editSelectedParticipantsMap.clear();
    editReceiptFile = null;
    editBillImageFile = null;
    editReceiptUrl = null;
    editBillImageUrl = null;
    editDueDate = null;
    notifyListeners();
  }

  void checkIfEditAmountsAreEqual() {
    final participants = getEditSelectedParticipants();
    if (participants.isEmpty) {
      isEditAmountEqual = false;
      notifyListeners();
      return;
    }

    final firstAmount =
        participants[0].amountController?.text.replaceAll(',', '') ?? '0';
    isEditAmountEqual = participants.every(
      (participant) =>
          participant.amountController?.text.replaceAll(',', '') == firstAmount,
    );
    notifyListeners();
  }

  void checkIfEditSplitBillIsComplete() {
    if (editTitleController.text.isNotEmpty &&
        editDescriptionController.text.isNotEmpty &&
        editTotalAmountController.text.isNotEmpty &&
        editDueDate != null &&
        editSelectedParticipantsMap.isNotEmpty) {
      isEditSplitBillFormComplete = true;
      notifyListeners();
    } else {
      isEditSplitBillFormComplete = false;
      notifyListeners();
    }
  }

  void toggleEditAllowPartialPayments(bool value) {
    editAllowPartialPayments = value;
    notifyListeners();
  }

  void addEditParticipant(dynamic participant) {
    final id = participant.id ?? "";
    if (!editSelectedParticipantsMap.containsKey(id)) {
      editSelectedParticipantsMap[id] = participant;
      applyEditEqualSplit();
      notifyListeners();
    }
  }

  void removeEditParticipant(String participantId) {
    editSelectedParticipantsMap.remove(participantId);
    applyEditEqualSplit();
    notifyListeners();
  }

  List<dynamic> getEditSelectedParticipants() =>
      editSelectedParticipantsMap.values.toList();

  void applyEditEqualSplit() {
    final participants = getEditSelectedParticipants();

    if (participants.isEmpty) return;

    final totalAmount =
        double.tryParse(editTotalAmountController.text.replaceAll(',', '')) ??
        0.0;
    final splitAmount = totalAmount / participants.length;
    final splitPercentage = 100.0 / participants.length;

    for (var participant in participants) {
      participant.amountController ??= TextEditingController();
      participant.amountController!.text = splitAmount.toStringAsFixed(2);

      participant.percentageController ??= TextEditingController();
      participant.percentageController!.text = splitPercentage
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'\.00$'), '');
    }
    notifyListeners();
  }

  Future<bool> updateSplitBill({required String splitBillId}) async {
    EasyLoading.show();
    List<Map> formattedParticipant = [];
    final participants = getEditSelectedParticipants();

    // The backend uses totalAmount as double
    double totalAmount =
        double.tryParse(editTotalAmountController.text.replaceAll(',', '')) ??
        0.0;

    for (var participant in participants) {
      double amount;
      if (isEditAmountEqual) {
        amount = totalAmount / participants.length;
      } else {
        amount =
            double.tryParse(
              participant.amountController?.text.replaceAll(',', '') ?? '0',
            ) ??
            0.0;
      }

      if (participant.type == "USER") {
        formattedParticipant.add({
          "type": "USER",
          "userId": participant.id,
          "amount": amount,
        });
      } else if (participant.type == "GUEST") {
        formattedParticipant.add({
          "type": "GUEST",
          "name": participant.name,
          "phone": formatPhoneNumber(participant.phoneNumber),
          "amount": amount,
        });
      }
    }

    try {
      final updatedData = {
        "title": editTitleController.text,
        "description": editDescriptionController.text,
        "amount": totalAmount,
        if (editBillImageUrl != null) "imageUrl": editBillImageUrl,
        "dueDate": editDueDate?.toIso8601String(),
        "participants": formattedParticipant,
        if (editReceiptUrl != null) "billReceipt": editReceiptUrl,
        "allowPartialPayment": editAllowPartialPayments,
        "minPaymentAmount":
            double.tryParse(
              editMinPaymentAmountForPartial.text.replaceAll(",", ""),
            ) ??
            0.0,
        "splitMethod": editSplitMethod,
      };

      final res = await splitBillApi.updateSplitBill(
        splitBillId: splitBillId,
        updatedData: updatedData,
      );

      if (res != null) {
        return true;
      }
      return false;
    } catch (e, stack) {
      log("ERROR UPDATING SPLIT BILL: $e", stackTrace: stack);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
  // ==========================

  void checkIfSplitBillIsComplete() {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        totalAmountController.text.isNotEmpty &&
        dueDate != null &&
        selectedParticipantsMap.isNotEmpty) {
      isSplitBillFormComplete = true;
      notifyListeners();
    } else {
      isSplitBillFormComplete = false;
      notifyListeners();
    }
  }

  void toggleAllowPartialPayments(bool value) {
    allowPartialPayments = value;
    notifyListeners();
  }

  void addParticipant(dynamic participant) {
    final id = participant.id ?? "";
    if (!selectedParticipantsMap.containsKey(id)) {
      selectedParticipantsMap[id] = participant;
      applyEqualSplit(); // Automatically split evenly when participant is added
      notifyListeners();
    }
  }

  void removeParticipant(String participantId) {
    selectedParticipantsMap.remove(participantId);
    applyEqualSplit(); // Automatically split evenly when participant is removed
    notifyListeners();
  }

  // this will hold the name and phone from the selected contact
  String temporaryGuestName = "";
  String temporaryGuestPhone = "";
  Future<void> handleSelectContact(BuildContext context) async {
    try {
      // Request contacts permission
      if (await FlutterContacts.requestPermission()) {
        // Open device contact picker
        final Contact? contact = await FlutterContacts.openExternalPick();

        if (contact != null && contact.phones.isNotEmpty) {
          // Extract phone number and clean it
          final phoneNumber = contact.phones.first.number.replaceAll(
            RegExp(r'\D'),
            '',
          ); // Remove non-digits

          log("Selected contact phone number: $phoneNumber");

          if (phoneNumber.isNotEmpty) {
            // Run search for this phone number - format by replacing 234 or +234 with 0
            String formattedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
            if (formattedPhone.startsWith('234')) {
              formattedPhone = '0${formattedPhone.substring(3)}';
            }
            temporaryGuestName = contact.displayName;
            temporaryGuestPhone = formattedPhone;
            await searchForUser(identifier: formattedPhone);
          }
        }
      } else {
        showErrorToast("Permission to access contacts is required");
      }
    } catch (e) {
      showErrorToast("Error accessing contacts");
    }
  }

  List<dynamic> getSelectedParticipants() =>
      selectedParticipantsMap.values.toList();

  // create split bill
  Future<bool> createSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    String? imageUrl,
    String? receiptUrl,
    required String dueDateIso8601,
    required List participants,
    bool? isEqualSplit,
  }) async {
    EasyLoading.show();
    // log("Is")
    List<Map> formattedParticipant = [];
    for (var participant in participants) {
      double amount;
      if (isEqualSplit ?? false) {
        amount = totalAmount / participants.length;
      } else {
        amount =
            double.tryParse(
              participant.amountController?.text.replaceAll(',', '') ?? '0',
            ) ??
            0.0;
      }

      if (participant.type == "USER") {
        formattedParticipant.add({
          "type": "USER",
          "userId": participant.id,
          "amount": amount,
        });
      } else if (participant.type == "GUEST") {
        formattedParticipant.add({
          "type": "GUEST",
          "name": participant.name,
          "phone": formatPhoneNumber(participant.phoneNumber),
          "amount": amount,
        });
      }
    }
    notifyListeners();
    try {
      await splitBillApi.createNewSplitBill(
        title: title,
        description: description,
        totalAmount: totalAmount,
        imageUrl: imageUrl,
        dueDate: dueDateIso8601,
        participants: formattedParticipant,
        billReceipt: receiptUrl,
        allowPartialPayments: allowPartialPayments,
        minPaymentAmountForPartial:
            double.tryParse(
              minPaymentAmountForPartial.text.replaceAll(",", ""),
            ) ??
            0.0,
        splitMethod: splitMethod,
      );
      Get.to(SplitBillSuccessScreen(title: title));
      return true;
    } catch (e, stack) {
      log("ERROR CREATING SPLIT BILL: $e", stackTrace: stack);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  List<SplitBillDatum> userSplitBills = [];
  ViewState userSplitBillState = ViewState.Idle;
  Future<bool> getCurrentUserSplitBill() async {
    setCustomState(ViewState state) {
      userSplitBillState = state;
      notifyListeners();
    }

    try {
      setCustomState(ViewState.Busy);
      await splitBillApi.getCurrentUserSplitBill();
      setCustomState(ViewState.Success);
      notifyListeners();
      return true;
    } catch (e, stack) {
      log("ERROR FETCHING CURRENT USER SPLIT BILL: $e", stackTrace: stack);
      setCustomState(ViewState.Error);

      return false;
    }
  }

  SplitBillDetailsModel? splitBillDetails;
  ViewState splitBillDetailsState = ViewState.Idle;
  Future<bool> getSplitBillDetails({required String splitBillId}) async {
    setCustomState(ViewState state) {
      splitBillDetailsState = state;
      notifyListeners();
    }

    try {
      setCustomState(ViewState.Busy);
      splitBillDetails = await splitBillApi.getSplitBillDetails(splitBillId);
      setCustomState(ViewState.Success);
      return true;
    } catch (e, stack) {
      log("ERROR FETCHING SPLIT BILL DETAILS: $e", stackTrace: stack);
      setCustomState(ViewState.Error);
      return false;
    }
  }

  List<AllUsersModel> searchResults = [];
  ViewState searchUserState = ViewState.Idle;
  Future<bool> searchForUser({
    String? identifier,
    bool forMyself = false,
  }) async {
    log("Searching for user with identifier: $identifier");
    setCustomState(ViewState state) {
      searchUserState = state;
      notifyListeners();
    }

    if (identifier == null || identifier.isEmpty) {
      searchUserState = ViewState.Idle;
      searchResults.clear();
      notifyListeners();
      return true;
    }

    // Determine what kind of identifier was passed
    String formattedIdentifier = identifier.trim();
    bool isEmail = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(formattedIdentifier);

    // Remove all non-digit characters for phone number check
    final digitsOnly = formattedIdentifier.replaceAll(RegExp(r'\D'), '');
    bool isPhone = digitsOnly.length >= 10 && digitsOnly.length <= 15;

    if (isPhone) {
      // It's a phone number. Format it appropriately or just use digits.
      if (digitsOnly.length == 11) {
        // It's a standard Nigerian phone number length (080...)
      } else if (digitsOnly.length == 13 &&
          formattedIdentifier.startsWith('+234')) {
        // Standard international Nigerian phone length
      } else if (digitsOnly.length < 10) {
        // Fallback catch, maybe just invalid
        searchUserState = ViewState.Idle;
        searchResults.clear();
        notifyListeners();
        return true;
      }
      formattedIdentifier = formatPhoneNumber(
        formattedIdentifier,
      ).replaceAll("+", "");
    }

    try {
      forMyself ? null : setCustomState(ViewState.Busy);
      var res = await splitBillApi.searchForUser(
        email: isEmail ? formattedIdentifier : null,
        username: (!isEmail && !isPhone) ? formattedIdentifier : null,
        phoneNumber: isPhone ? formattedIdentifier : null,
      );
      searchResults = res;
      if (res.isEmpty) {
        forMyself ? null : setCustomState(ViewState.NoDataAvailable);

        return true;
      }
      forMyself ? null : setCustomState(ViewState.Success);
      // clear out the temp guest info since the user exist
      temporaryGuestName = "";
      temporaryGuestPhone = "";
      notifyListeners();
      return true;
    } catch (e, stack) {
      log("ERROR SEARCHING FOR USER: $e", stackTrace: stack);
      forMyself ? null : setCustomState(ViewState.Error);
      return false;
    }
  }

  /// Adds current user to bill by searching with their phone number
  Future<bool> addCurrentUserToBill({required String phoneNumber}) async {
    log("Adding current user to bill with phone number: $phoneNumber");
    // if (phoneNumber.isEmpty) return false;
    EasyLoading.show();

    try {
      // Search for the current user
      await searchForUser(
        identifier: formatPhoneNumber(phoneNumber).replaceAll("+234", "0"),
        forMyself: true,
      );

      // If user found, add the first result
      if (searchResults.isNotEmpty) {
        final currentUserData = CustomParticipantClass.fromUser(
          searchResults[0],
        );
        // Insert at the beginning of the map to make it first
        final newMap = <String, dynamic>{currentUserData.id: currentUserData};
        newMap.addAll(selectedParticipantsMap);
        selectedParticipantsMap = newMap;
        // searchResults.clear();
        checkIfSplitBillIsComplete();
        return true;
      }
      return false;
    } catch (e, stack) {
      log("ERROR ADDING CURRENT USER: $e", stackTrace: stack);
      return false;
    } finally {
      // searchResults.clear();
      EasyLoading.dismiss();
    }
  }

  /// Adds a participant from contact data
  void addParticipantFromContact({
    required String name,
    required String phoneNumber,
  }) {
    if (name.isEmpty || phoneNumber.isEmpty) return;

    try {
      final contactParticipant = CustomParticipantClass.guest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phoneNumber: phoneNumber,
      );
      addParticipant(contactParticipant);
    } catch (e, stack) {
      log("ERROR ADDING CONTACT PARTICIPANT: $e", stackTrace: stack);
    }
  }

  void disposeCreateSplitBill() {
    // Dispose controllers
    titleController.clear();
    descriptionController.clear();
    totalAmountController.clear();
    newSplitBillTitleController.clear();
    searchParticipantController.clear();
    userSplitBills.clear();
    searchUserState = ViewState.Idle;
    selectedParticipantsMap.clear();
    receiptFile = null;
    billImageFile = null;
    notifyListeners();
  }

  void clearSearchResults() {
    searchResults.clear();
    searchUserState = ViewState.Idle;
    notifyListeners();
  }

  void applyEqualSplit() {
    final participants = getSelectedParticipants();

    if (participants.isEmpty) return;

    final totalAmount =
        double.tryParse(totalAmountController.text.replaceAll(',', '')) ?? 0.0;
    final splitAmount = totalAmount / participants.length;
    final splitPercentage = 100.0 / participants.length;

    for (var participant in participants) {
      participant.amountController ??= TextEditingController();
      participant.amountController!.text = splitAmount.toStringAsFixed(2);

      participant.percentageController ??= TextEditingController();
      participant.percentageController!.text = splitPercentage
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'\.00$'), '');
    }
    notifyListeners();
  }

  // implement image upload using uploadBillReceipt
  Future<String?> uploadImage(File file) async {
    EasyLoading.show(status: "Uploading image...");
    try {
      return await splitBillApi.uploadBillReceipt(file);
    } catch (e, stack) {
      log("ERROR UPLOADING IMAGE: $e", stackTrace: stack);
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }

  var mySplitBill = MySplitBillModel();
  ViewState mySplitBillState = ViewState.Idle;
  Future<bool> getMySplitBills() async {
    setCustomState(ViewState state) {
      mySplitBillState = state;
      notifyListeners();
    }

    setCustomState(ViewState.Busy);
    try {
      mySplitBill = await splitBillApi.getMySplitBills();
      if (mySplitBill.bills?.isEmpty ?? false) {
        setCustomState(ViewState.NoDataAvailable);
        return true;
      }
      setCustomState(ViewState.Success);
      return true;
    } catch (e, stack) {
      log("Get My Split bill Error$e", stackTrace: stack);
      setCustomState(ViewState.Error);
      return false;
    }
  }

  var splitBillInvites = SplitBillInviteModel();
  ViewState splitBillInvitesState = ViewState.Idle;
  Future<bool> getSplitBillInvites() async {
    setCustomState(ViewState state) {
      splitBillInvitesState = state;
      notifyListeners();
    }

    setCustomState(ViewState.Busy);
    try {
      splitBillInvites = await splitBillApi.getSplitBillInvites();
      if (splitBillInvites.invites?.isEmpty ?? false) {
        setCustomState(ViewState.NoDataAvailable);
        return true;
      }
      setCustomState(ViewState.Success);
      return true;
    } catch (e, stack) {
      log("Get my split bill invites error: $e", stackTrace: stack);
      setCustomState(ViewState.Error);
      return false;
    }
  }

  Future<bool> acceptSplitBillInvite(String billId) async {
    try {
      await splitBillApi.acceptSplitBillInvite(billId);
      await getSplitBillInvites();
      return true;
    } catch (e, stack) {
      log("Accept split bill invite error: $e", stackTrace: stack);
      return false;
    }
  }

  Future<bool> declineSplitBillInvite(String billId) async {
    try {
      EasyLoading.show();
      await splitBillApi.declineSplitBillInvite(billId);
      await getSplitBillInvites();
      return true;
    } catch (e, stack) {
      log("Decline split bill invite error: $e", stackTrace: stack);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> sendSplitBillReminder(String billId) async {
    EasyLoading.show(status: 'Sending reminders...');
    try {
      await splitBillApi.sendSplitBillReminder(billId);
      EasyLoading.dismiss();
      showSuccessToast('Reminders sent to participants');
    } catch (e) {
      EasyLoading.dismiss();
      showErrorToast(e.toString());
    }
  }

  Future<bool> payForSPlitBillWithWallet({
    String? participantId,
    String? billId,
    String? amount,
    String? transactionPin,
  }) async {
    EasyLoading.show(status: "Processing payment...");

    try {
      await splitBillApi.payForBillWithWallet(
        participantId: participantId,
        billId: billId,
        amount: amount,
        transactionPin: transactionPin,
      );

      return true;
    } catch (e, stack) {
      log("Get my split bill invites error: $e", stackTrace: stack);
      showErrorToast(" ${e.toString()}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<String> payForSPlitBillWithPaystack({
    String? participantId,
    String? billId,
    String? amount,
  }) async {
    EasyLoading.show(status: "Processing payment...");

    try {
      await splitBillApi.payForBillWithPaystack(
        participantId: participantId,
        billId: billId,
        amount: amount,
      );

      return "";
    } catch (e, stack) {
      log("Get my split bill invites error: $e", stackTrace: stack);
      return "";
    } finally {
      EasyLoading.dismiss();
    }
  }
}

/// Unified participant model supporting USER and GUEST types
class CustomParticipantClass {
  final String type; // "USER" or "GUEST"
  final String id;
  final String name;
  final String phoneNumber;
  final String? imageUrl;
  final String? firstName;
  final String? username;
  TextEditingController? amountController;
  TextEditingController? percentageController;

  CustomParticipantClass({
    required this.type,
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.imageUrl,
    this.firstName,
    this.username,
    this.amountController,
    this.percentageController,
  });

  factory CustomParticipantClass.fromUser(AllUsersModel user) {
    return CustomParticipantClass(
      type: "USER",
      id: user.id ?? "",
      name: user.username ?? user.firstName ?? "Unknown",
      phoneNumber: user.phoneNumber ?? "",
      imageUrl: user.profile?.image,
      firstName: user.firstName,
      username: user.username,
    );
  }

  factory CustomParticipantClass.guest({
    required String id,
    required String name,
    required String phoneNumber,
  }) {
    return CustomParticipantClass(
      type: "GUEST",
      id: id,
      name: name,
      phoneNumber: phoneNumber,
    );
  }
}
