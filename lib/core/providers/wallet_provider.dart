import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/wallet_api/wallet_api.dart';
import 'package:greyfundr/core/models/wallet_model.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';

class WalletProvider extends BaseNotifier {
  var walletApi = locator<WalletApi>();

  WalletModel? walletModel;
  Future<bool> fetchUserWallet() async {
    // EasyLoading.show();
    try {
      walletModel = await walletApi.getWallet();
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON FETCH USER WALLET $e ");
      showErrorToast("${e}");
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
      showErrorToast("${e}");
      return "";
    } finally {
      EasyLoading.dismiss();
    }
  }
}
