import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/wallet_api/wallet_api.dart';
import 'package:greyfundr/core/models/wallet_model.dart';
import 'package:greyfundr/core/models/transaction_model.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';

class WalletProvider extends BaseNotifier {
  var walletApi = locator<WalletApi>();

  WalletModel? walletModel;
  TransactionModel? transactionModel;
  bool isFetchingTransactions = false;

  Future<bool> fetchUserWallet() async {
    // EasyLoading.show();
    try {
      walletModel = await walletApi.getWallet();
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON FETCH USER WALLET $e ");
      showErrorToast("$e");
      return false;
    } finally {
      // EasyLoading.dismiss();
    }
  }

  Future<String> initiateWalletFunding({required String amount}) async {
    EasyLoading.show();
    try {
      final url = await walletApi.initiateFund(amount: amount);
      notifyListeners();
      return url;
    } catch (e) {
      log("ERROR ON INITIATE WALLET FUNDING $e ");
      showErrorToast("$e");
      return "";
    } finally {
      EasyLoading.dismiss();
    }
  }

  ViewState transactionState = ViewState.Idle;
  Future<void> fetchTransactions({int page = 1, int limit = 20}) async {
    transactionState = ViewState.Busy;
    notifyListeners();
    try {
      transactionModel = await walletApi.getTransactions(
        page: page,
        limit: limit,
      );
      transactionState = ViewState.Success;
      notifyListeners();
    } catch (e, stacktrace) {
      log("ERROR ON FETCH TRANSACTIONS $e :::: $stacktrace");
      showErrorToast("$e");
      transactionState = ViewState.Error;
      notifyListeners();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> setTransactionPin({
    required String pin,
    required String confirmPin,
  }) async {
    EasyLoading.show(status: 'Setting transaction pin...');
    try {
      await walletApi.setTransactionPin(pin: pin, confirmPin: confirmPin);
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      showErrorToast("$e");
      EasyLoading.dismiss();
      return false;
    }
  }

  Future<bool> changeTransactionPin({
    required String currentPin,
    required String newPin,
    required String confirmPin,
  }) async {
    EasyLoading.show(status: 'Updating transaction pin...');
    try {
      EasyLoading.show();
      await walletApi.changeTransactionPin(
        currentPin: currentPin,
        newPin: newPin,
        confirmPin: confirmPin,
      );
      return true;
    } catch (e) {
      showErrorToast("$e");
      if ("${e}".contains("Current PIN is incorrect")) {
        Get.close(2);
      }
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
