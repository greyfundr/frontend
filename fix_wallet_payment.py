import sys

with open('lib/core/api/splitbill_api/splitbill_api.dart', 'r') as f:
    api_dart = f.read()

api_dart = api_dart.replace(
    "String? amount,\n   });",
    "String? amount,\n    String? transactionPin,\n  });"
)
with open('lib/core/api/splitbill_api/splitbill_api.dart', 'w') as f:
    f.write(api_dart)

with open('lib/core/api/splitbill_api/splitbill_api_impl.dart', 'r') as f:
    impl_dart = f.read()

impl_dart = impl_dart.replace(
    """  Future payForBillWithWallet({
    String? participantId,
    String? billId,
    String? amount,
  }) async {
    final responseBody = await _apiClient.post(
      "${ApiRoute.getSplitBillRoute}/$billId/participants/$participantId/pay",
      body: {
        "amount": amount != null ? double.tryParse(amount)?.toInt() ?? 0 : 0,
        "paymentMethod": "wallet",
      },""",
    """  Future payForBillWithWallet({
    String? participantId,
    String? billId,
    String? amount,
    String? transactionPin,
  }) async {
    final responseBody = await _apiClient.post(
      "${ApiRoute.getSplitBillRoute}/$billId/participants/$participantId/pay",
      body: {
        "amount": amount != null ? double.tryParse(amount.replaceAll(',', '')) ?? 0.0 : 0.0,
        "paymentMethod": "wallet",
        if (transactionPin != null) "transactionPin": transactionPin,
      },"""
)

with open('lib/core/api/splitbill_api/splitbill_api_impl.dart', 'w') as f:
    f.write(impl_dart)

with open('lib/features/new_split_bill/split_bill_provider.dart', 'r') as f:
    prov_dart = f.read()

prov_dart = prov_dart.replace(
    """  Future<bool> payForSPlitBillWithWallet({
    String? participantId,
    String? billId,
    String? amount,
  }) async {
    EasyLoading.show(status: "Processing payment...");

    try {
      await splitBillApi.payForBillWithWallet(
        participantId: participantId,
        billId: billId,
        amount: amount,
      );""",
    """  Future<bool> payForSPlitBillWithWallet({
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
      );"""
)

with open('lib/features/new_split_bill/split_bill_provider.dart', 'w') as f:
    f.write(prov_dart)

