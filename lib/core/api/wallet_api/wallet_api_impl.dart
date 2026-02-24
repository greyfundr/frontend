import 'dart:convert';

import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/wallet_api/wallet_api.dart';
import 'package:greyfundr/core/models/wallet_model.dart';

class WalletApiImpl implements WalletApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  Future<WalletModel> getWallet() async {
    final response = await _apiClient.get(
      ApiRoute.walletRoute,
      headers: header,
    );
    return walletModelFromJson(response);
  }

  @override
  Future<dynamic> getWalletBalance() async {
    final response = await _apiClient.get(
      ApiRoute.walletBalanceRoute,
      headers: header,
    );
    return response;
  }

  @override
  Future<dynamic> provisionVirtualAccount() async {
    final response = await _apiClient.post(
      ApiRoute.provisionVirtualAccountRoute,
      headers: header,
    );
    return response;
  }

  @override
  Future<dynamic> getFundingAccount() async {
    final response = await _apiClient.get(
      ApiRoute.fundingAccountRoute,
      headers: header,
    );
    return response;
  }

  @override
  Future<String> initiateFund({required String amount}) async {
    final response = await _apiClient.post(
      ApiRoute.fundInitiateRoute,
      headers: header,
      body: {"amount": int.parse(amount) * 100},
    );
    var decodedResponse = jsonDecode(response);
    return decodedResponse['authorizationUrl'];
  }

  @override
  Future<dynamic> verifyFund({required String reference}) async {
    final response = await _apiClient.get(
      "${ApiRoute.fundVerifyRoute}/$reference",
      headers: header,
    );
    return response;
  }

  @override
  Future<dynamic> getBankAccounts() async {
    final response = await _apiClient.get(
      ApiRoute.bankAccountsRoute,
      headers: header,
    );
    return response;
  }

  @override
  Future<dynamic> addBankAccount({required Map<String, dynamic> data}) async {
    final response = await _apiClient.post(
      ApiRoute.bankAccountsRoute,
      headers: header,
      body: data,
    );
    return response;
  }

  @override
  Future<dynamic> deleteBankAccount({required String id}) async {
    final response = await _apiClient.delete(
      "${ApiRoute.bankAccountsRoute}/$id",
      headers: header,
    );
    return response;
  }

  @override
  Future<dynamic> withdraw({required Map<String, dynamic> data}) async {
    final response = await _apiClient.post(
      ApiRoute.withdrawRoute,
      headers: header,
      body: data,
    );
    return response;
  }
}
