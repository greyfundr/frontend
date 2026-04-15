import 'package:greyfundr/core/models/transaction_model.dart';

abstract class WalletApi {
  Future<dynamic> getWallet();
  Future<dynamic> getWalletBalance();
  Future<dynamic> provisionVirtualAccount();
  Future<dynamic> getFundingAccount();
  Future<dynamic> initiateFund({required String amount});
  Future<dynamic> verifyFund({required String reference});
  Future<dynamic> getBankAccounts();
  Future<dynamic> addBankAccount({required Map<String, dynamic> data});
  Future<dynamic> deleteBankAccount({required String id});
  Future<dynamic> withdraw({required Map<String, dynamic> data});
  Future<Map<String, dynamic>> contributeToEvent({
    required String id,
    required Map<String, dynamic> payload,
  });
  Future<TransactionModel> getTransactions({int page = 1, int limit = 20});
  Future<bool> setTransactionPin({required String pin, required String confirmPin});
  Future<bool> changeTransactionPin({required String currentPin, required String newPin, required String confirmPin});
}
