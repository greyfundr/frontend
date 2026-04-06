// To parse this JSON data, do
//
//     final transactionModel = transactionModelFromJson(jsonString);

import 'dart:convert';

TransactionModel transactionModelFromJson(String str) => TransactionModel.fromJson(json.decode(str));

String transactionModelToJson(TransactionModel data) => json.encode(data.toJson());

class TransactionModel {
    List<Datum>? data;
    Meta? meta;

    TransactionModel({
        this.data,
        this.meta,
    });

    factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "meta": meta?.toJson(),
    };
}

class Datum {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    String? walletId;
    dynamic? amount;
    String? currency;
    String? type;
    String? direction;
    String? status;
    String? reference;
    String? gatewayReference;
    dynamic idempotencyKey;
    String? description;
    dynamic failureReason;
    dynamic sourceRef;
    dynamic counterpartyWalletId;
    dynamic? feeAmount;
    dynamic gatewayResponse;
    Metadata? metadata;
    DateTime? confirmedAt;

    Datum({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.walletId,
        this.amount,
        this.currency,
        this.type,
        this.direction,
        this.status,
        this.reference,
        this.gatewayReference,
        this.idempotencyKey,
        this.description,
        this.failureReason,
        this.sourceRef,
        this.counterpartyWalletId,
        this.feeAmount,
        this.gatewayResponse,
        this.metadata,
        this.confirmedAt,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        walletId: json["walletId"],
        amount: json["amount"],
        currency: json["currency"],
        type: json["type"],
        direction: json["direction"],
        status: json["status"],
        reference: json["reference"],
        gatewayReference: json["gatewayReference"],
        idempotencyKey: json["idempotencyKey"],
        description: json["description"],
        failureReason: json["failureReason"],
        sourceRef: json["sourceRef"],
        counterpartyWalletId: json["counterpartyWalletId"],
        feeAmount: json["feeAmount"],
        gatewayResponse: json["gatewayResponse"],
        metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
        confirmedAt: json["confirmedAt"] == null ? null : DateTime.parse(json["confirmedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "walletId": walletId,
        "amount": amount,
        "currency": currency,
        "type": type,
        "direction": direction,
        "status": status,
        "reference": reference,
        "gatewayReference": gatewayReference,
        "idempotencyKey": idempotencyKey,
        "description": description,
        "failureReason": failureReason,
        "sourceRef": sourceRef,
        "counterpartyWalletId": counterpartyWalletId,
        "feeAmount": feeAmount,
        "gatewayResponse": gatewayResponse,
        "metadata": metadata?.toJson(),
        "confirmedAt": confirmedAt?.toIso8601String(),
    };
}

class Metadata {
    String? userId;
    String? initiatedBy;
    String? channel;

    Metadata({
        this.userId,
        this.initiatedBy,
        this.channel,
    });

    factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        userId: json["userId"],
        initiatedBy: json["initiatedBy"],
        channel: json["channel"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "initiatedBy": initiatedBy,
        "channel": channel,
    };
}

class Meta {
    int? total;
    int? page;
    int? limit;
    int? totalPages;
    bool? hasNextPage;
    bool? hasPreviousPage;

    Meta({
        this.total,
        this.page,
        this.limit,
        this.totalPages,
        this.hasNextPage,
        this.hasPreviousPage,
    });

    factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        hasNextPage: json["hasNextPage"],
        hasPreviousPage: json["hasPreviousPage"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "page": page,
        "limit": limit,
        "totalPages": totalPages,
        "hasNextPage": hasNextPage,
        "hasPreviousPage": hasPreviousPage,
    };
}
