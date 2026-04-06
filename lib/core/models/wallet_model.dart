// To parse this JSON data, do
//
//     final walletModel = walletModelFromJson(jsonString);

import 'dart:convert';

WalletModel walletModelFromJson(String str) =>
    WalletModel.fromJson(json.decode(str));

String walletModelToJson(WalletModel data) => json.encode(data.toJson());

class WalletModel {
  String? id;
  String? status;
  String? currency;
  Balance? balance;
  dynamic virtualAccount;

  WalletModel({
    this.id,
    this.status,
    this.currency,
    this.balance,
    this.virtualAccount,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    id: json["id"],
    status: json["status"],
    currency: json["currency"],
    balance: json["balance"] == null ? null : Balance.fromJson(json["balance"]),
    virtualAccount: json["virtualAccount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "currency": currency,
    "balance": balance?.toJson(),
    "virtualAccount": virtualAccount,
  };
}

class Balance {
  dynamic available;
  dynamic ledger;
  dynamic escrow;
  dynamic currency;

  Balance({this.available, this.ledger, this.escrow, this.currency});

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
    available: json["available"],
    ledger: json["ledger"],
    escrow: json["escrow"],
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "available": available,
    "ledger": ledger,
    "escrow": escrow,
    "currency": currency,
  };
}
