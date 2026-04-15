// To parse this JSON data, do
//
//     final splitBillInviteModel = splitBillInviteModelFromJson(jsonString);

import 'dart:convert';

SplitBillInviteModel splitBillInviteModelFromJson(String str) => SplitBillInviteModel.fromJson(json.decode(str));

String splitBillInviteModelToJson(SplitBillInviteModel data) => json.encode(data.toJson());

class SplitBillInviteModel {
    List<Invite>? invites;
    int? total;
    int? page;
    int? totalPages;

    SplitBillInviteModel({
        this.invites,
        this.total,
        this.page,
        this.totalPages,
    });

    factory SplitBillInviteModel.fromJson(Map<String, dynamic> json) => SplitBillInviteModel(
        invites: json["invites"] == null ? [] : List<Invite>.from(json["invites"]!.map((x) => Invite.fromJson(x))),
        total: json["total"],
        page: json["page"],
        totalPages: json["totalPages"],
    );

    Map<String, dynamic> toJson() => {
        "invites": invites == null ? [] : List<dynamic>.from(invites!.map((x) => x.toJson())),
        "total": total,
        "page": page,
        "totalPages": totalPages,
    };
}

class Invite {
    String? participantId;
    String? inviteCode;
    DateTime? inviteExpiresAt;
    DateTime? invitedAt;
    dynamic amountOwed;
    dynamic percentage;
    String? currency;
    String? splitMethod;
    Bill? bill;
    CreatedBy? createdBy;

    Invite({
        this.participantId,
        this.inviteCode,
        this.inviteExpiresAt,
        this.invitedAt,
        this.amountOwed,
        this.percentage,
        this.currency,
        this.splitMethod,
        this.bill,
        this.createdBy,
    });

    factory Invite.fromJson(Map<String, dynamic> json) => Invite(
        participantId: json["participantId"],
        inviteCode: json["inviteCode"],
        inviteExpiresAt: json["inviteExpiresAt"] == null ? null : DateTime.parse(json["inviteExpiresAt"]),
        invitedAt: json["invitedAt"] == null ? null : DateTime.parse(json["invitedAt"]),
        amountOwed: json["amountOwed"],
        percentage: json["percentage"],
        currency: json["currency"],
        splitMethod: json["splitMethod"],
        bill: json["bill"] == null ? null : Bill.fromJson(json["bill"]),
        createdBy: json["createdBy"] == null ? null : CreatedBy.fromJson(json["createdBy"]),
    );

    Map<String, dynamic> toJson() => {
        "participantId": participantId,
        "inviteCode": inviteCode,
        "inviteExpiresAt": inviteExpiresAt?.toIso8601String(),
        "invitedAt": invitedAt?.toIso8601String(),
        "amountOwed": amountOwed,
        "percentage": percentage,
        "currency": currency,
        "splitMethod": splitMethod,
        "bill": bill?.toJson(),
        "createdBy": createdBy?.toJson(),
    };
}

class Bill {
    String? id;
    String? title;
    String? description;
    String? imageUrl;
    int? totalAmount;
    int? totalParticipants;
    String? currency;
    String? splitMethod;
    String? status;
    DateTime? dueDate;
    dynamic shareLink;
    DateTime? createdAt;

    Bill({
        this.id,
        this.title,
        this.description,
        this.imageUrl,
        this.totalAmount,
        this.totalParticipants,
        this.currency,
        this.splitMethod,
        this.status,
        this.dueDate,
        this.shareLink,
        this.createdAt,
    });

    factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        totalAmount: json["totalAmount"],
        totalParticipants: json["totalParticipants"],
        currency: json["currency"],
        splitMethod: json["splitMethod"],
        status: json["status"],
        dueDate: json["dueDate"] == null ? null : DateTime.parse(json["dueDate"]),
        shareLink: json["shareLink"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "totalAmount": totalAmount,
        "totalParticipants": totalParticipants,
        "currency": currency,
        "splitMethod": splitMethod,
        "status": status,
        "dueDate": dueDate?.toIso8601String(),
        "shareLink": shareLink,
        "createdAt": createdAt?.toIso8601String(),
    };
}

class CreatedBy {
    String? id;
    String? name;
    String? username;

    CreatedBy({
        this.id,
        this.name,
        this.username,
    });

    factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["id"],
        name: json["name"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
    };
}
