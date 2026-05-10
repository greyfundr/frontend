// To parse this JSON data, do
//
//     final queryNotificationModel = queryNotificationModelFromJson(jsonString);

import 'dart:convert';

QueryNotificationModel queryNotificationModelFromJson(String str) => QueryNotificationModel.fromJson(json.decode(str));

String queryNotificationModelToJson(QueryNotificationModel data) => json.encode(data.toJson());

class QueryNotificationModel {
    List<SplitBillQueryDatum>? queries;
    int? total;
    int? page;
    int? totalPages;

    QueryNotificationModel({
        this.queries,
        this.total,
        this.page,
        this.totalPages,
    });

    factory QueryNotificationModel.fromJson(Map<String, dynamic> json) => QueryNotificationModel(
        queries: json["queries"] == null ? [] : List<SplitBillQueryDatum>.from(json["queries"]!.map((x) => SplitBillQueryDatum.fromJson(x))),
        total: json["total"],
        page: json["page"],
        totalPages: json["totalPages"],
    );

    Map<String, dynamic> toJson() => {
        "queries": queries == null ? [] : List<dynamic>.from(queries!.map((x) => x.toJson())),
        "total": total,
        "page": page,
        "totalPages": totalPages,
    };
}

class SplitBillQueryDatum {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    String? splitBillId;
    String? actorId;
    String? participantId;
    String? actionType;
    String? description;
    int? amountBefore;
    int? amountAfter;
    int? amountDifference;
    String? billStatusAtTime;
    dynamic transactionId;
    Metadata? metadata;

    SplitBillQueryDatum({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.splitBillId,
        this.actorId,
        this.participantId,
        this.actionType,
        this.description,
        this.amountBefore,
        this.amountAfter,
        this.amountDifference,
        this.billStatusAtTime,
        this.transactionId,
        this.metadata,
    });

    factory SplitBillQueryDatum.fromJson(Map<String, dynamic> json) => SplitBillQueryDatum(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        splitBillId: json["splitBillId"],
        actorId: json["actorId"],
        participantId: json["participantId"],
        actionType: json["actionType"],
        description: json["description"],
        amountBefore: json["amountBefore"],
        amountAfter: json["amountAfter"],
        amountDifference: json["amountDifference"],
        billStatusAtTime: json["billStatusAtTime"],
        transactionId: json["transactionId"],
        metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "splitBillId": splitBillId,
        "actorId": actorId,
        "participantId": participantId,
        "actionType": actionType,
        "description": description,
        "amountBefore": amountBefore,
        "amountAfter": amountAfter,
        "amountDifference": amountDifference,
        "billStatusAtTime": billStatusAtTime,
        "transactionId": transactionId,
        "metadata": metadata?.toJson(),
    };
}

class Metadata {
    String? currency;
    int? amountOwed;
    String? participantStatus;

    Metadata({
        this.currency,
        this.amountOwed,
        this.participantStatus,
    });

    factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        currency: json["currency"],
        amountOwed: json["amountOwed"],
        participantStatus: json["participantStatus"],
    );

    Map<String, dynamic> toJson() => {
        "currency": currency,
        "amountOwed": amountOwed,
        "participantStatus": participantStatus,
    };
}
