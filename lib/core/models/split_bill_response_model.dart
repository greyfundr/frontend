// To parse this JSON data, do
//
//     final splitBillResponseModel = splitBillResponseModelFromJson(jsonString);

import 'dart:convert';

SplitBillResponseModel splitBillResponseModelFromJson(String str) => SplitBillResponseModel.fromJson(json.decode(str));

String splitBillResponseModelToJson(SplitBillResponseModel data) => json.encode(data.toJson());

class SplitBillResponseModel {
    bool? success;
    String? message;
    List<SplitBillDatum>? data;
    Pagination? pagination;

    SplitBillResponseModel({
        this.success,
        this.message,
        this.data,
        this.pagination,
    });

    factory SplitBillResponseModel.fromJson(Map<String, dynamic> json) => SplitBillResponseModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<SplitBillDatum>.from(json["data"]!.map((x) => SplitBillDatum.fromJson(x))),
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
    };
}

class SplitBillDatum {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    String? title;
    String? description;
    String? imageUrl;
    String? billReceipt;
    dynamic totalAmount;
    dynamic totalCollected;
    String? currency;
    String? splitMethod;
    bool? isFinalized;
    dynamic finalizedAt;
    bool? allowPartialPayment;
    dynamic minPaymentAmount;
    int? totalParticipants;
    int? totalPaidParticipants;
    String? status;
    DateTime? dueDate;
    dynamic cancelledAt;
    dynamic cancellationReason;
    dynamic disputedAt;
    dynamic disputeReason;
    String? recipientUserId;
    dynamic sourceBillType;
    dynamic sourceBillId;
    String? visibility;
    int? reminderSentCount;
    dynamic lastReminderAt;
    dynamic reminderDaysBefore;
    String? creatorId;
    List<Participant>? participants;

    SplitBillDatum({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.title,
        this.description,
        this.imageUrl,
        this.billReceipt,
        this.totalAmount,
        this.totalCollected,
        this.currency,
        this.splitMethod,
        this.isFinalized,
        this.finalizedAt,
        this.allowPartialPayment,
        this.minPaymentAmount,
        this.totalParticipants,
        this.totalPaidParticipants,
        this.status,
        this.dueDate,
        this.cancelledAt,
        this.cancellationReason,
        this.disputedAt,
        this.disputeReason,
        this.recipientUserId,
        this.sourceBillType,
        this.sourceBillId,
        this.visibility,
        this.reminderSentCount,
        this.lastReminderAt,
        this.reminderDaysBefore,
        this.creatorId,
        this.participants,
    });

    factory SplitBillDatum.fromJson(Map<String, dynamic> json) => SplitBillDatum(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        title: json["title"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        billReceipt: json["billReceipt"],
        totalAmount: json["totalAmount"],
        totalCollected: json["totalCollected"],
        currency: json["currency"],
        splitMethod: json["splitMethod"],
        isFinalized: json["isFinalized"],
        finalizedAt: json["finalizedAt"],
        allowPartialPayment: json["allowPartialPayment"],
        minPaymentAmount: json["minPaymentAmount"],
        totalParticipants: json["totalParticipants"],
        totalPaidParticipants: json["totalPaidParticipants"],
        status: json["status"],
        dueDate: json["dueDate"] == null ? null : DateTime.parse(json["dueDate"]),
        cancelledAt: json["cancelledAt"],
        cancellationReason: json["cancellationReason"],
        disputedAt: json["disputedAt"],
        disputeReason: json["disputeReason"],
        recipientUserId: json["recipientUserId"],
        sourceBillType: json["sourceBillType"],
        sourceBillId: json["sourceBillId"],
        visibility: json["visibility"],
        reminderSentCount: json["reminderSentCount"],
        lastReminderAt: json["lastReminderAt"],
        reminderDaysBefore: json["reminderDaysBefore"],
        creatorId: json["creatorId"],
        participants: json["participants"] == null ? [] : List<Participant>.from(json["participants"]!.map((x) => Participant.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "billReceipt": billReceipt,
        "totalAmount": totalAmount,
        "totalCollected": totalCollected,
        "currency": currency,
        "splitMethod": splitMethod,
        "isFinalized": isFinalized,
        "finalizedAt": finalizedAt,
        "allowPartialPayment": allowPartialPayment,
        "minPaymentAmount": minPaymentAmount,
        "totalParticipants": totalParticipants,
        "totalPaidParticipants": totalPaidParticipants,
        "status": status,
        "dueDate": dueDate?.toIso8601String(),
        "cancelledAt": cancelledAt,
        "cancellationReason": cancellationReason,
        "disputedAt": disputedAt,
        "disputeReason": disputeReason,
        "recipientUserId": recipientUserId,
        "sourceBillType": sourceBillType,
        "sourceBillId": sourceBillId,
        "visibility": visibility,
        "reminderSentCount": reminderSentCount,
        "lastReminderAt": lastReminderAt,
        "reminderDaysBefore": reminderDaysBefore,
        "creatorId": creatorId,
        "participants": participants == null ? [] : List<dynamic>.from(participants!.map((x) => x.toJson())),
    };
}

class Participant {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    String? splitBillId;
    String? userId;
    dynamic guestName;
    dynamic guestPhone;
    dynamic guestEmail;
    String? role;
    dynamic amountOwed;
    dynamic amountPaid;
    dynamic amountRemaining;
    dynamic balanceAdjustment;
    dynamic percentage;
    String? status;
    String? inviteCode;
    DateTime? inviteExpiresAt;
    dynamic paymentLink;
    dynamic paymentLinkExpiresAt;
    dynamic walletId;
    dynamic paymentMethod;
    DateTime? invitedAt;
    dynamic acceptedAt;
    dynamic declinedAt;
    dynamic firstPaidAt;
    dynamic fullyPaidAt;
    int? reminderCount;
    dynamic lastRemindedAt;
    dynamic note;

    Participant({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.splitBillId,
        this.userId,
        this.guestName,
        this.guestPhone,
        this.guestEmail,
        this.role,
        this.amountOwed,
        this.amountPaid,
        this.amountRemaining,
        this.balanceAdjustment,
        this.percentage,
        this.status,
        this.inviteCode,
        this.inviteExpiresAt,
        this.paymentLink,
        this.paymentLinkExpiresAt,
        this.walletId,
        this.paymentMethod,
        this.invitedAt,
        this.acceptedAt,
        this.declinedAt,
        this.firstPaidAt,
        this.fullyPaidAt,
        this.reminderCount,
        this.lastRemindedAt,
        this.note,
    });

    factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        splitBillId: json["splitBillId"],
        userId: json["userId"],
        guestName: json["guestName"],
        guestPhone: json["guestPhone"],
        guestEmail: json["guestEmail"],
        role: json["role"],
        amountOwed: json["amountOwed"],
        amountPaid: json["amountPaid"],
        amountRemaining: json["amountRemaining"],
        balanceAdjustment: json["balanceAdjustment"],
        percentage: json["percentage"],
        status: json["status"],
        inviteCode: json["inviteCode"],
        inviteExpiresAt: json["inviteExpiresAt"] == null ? null : DateTime.parse(json["inviteExpiresAt"]),
        paymentLink: json["paymentLink"],
        paymentLinkExpiresAt: json["paymentLinkExpiresAt"],
        walletId: json["walletId"],
        paymentMethod: json["paymentMethod"],
        invitedAt: json["invitedAt"] == null ? null : DateTime.parse(json["invitedAt"]),
        acceptedAt: json["acceptedAt"],
        declinedAt: json["declinedAt"],
        firstPaidAt: json["firstPaidAt"],
        fullyPaidAt: json["fullyPaidAt"],
        reminderCount: json["reminderCount"],
        lastRemindedAt: json["lastRemindedAt"],
        note: json["note"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "splitBillId": splitBillId,
        "userId": userId,
        "guestName": guestName,
        "guestPhone": guestPhone,
        "guestEmail": guestEmail,
        "role": role,
        "amountOwed": amountOwed,
        "amountPaid": amountPaid,
        "amountRemaining": amountRemaining,
        "balanceAdjustment": balanceAdjustment,
        "percentage": percentage,
        "status": status,
        "inviteCode": inviteCode,
        "inviteExpiresAt": inviteExpiresAt?.toIso8601String(),
        "paymentLink": paymentLink,
        "paymentLinkExpiresAt": paymentLinkExpiresAt,
        "walletId": walletId,
        "paymentMethod": paymentMethod,
        "invitedAt": invitedAt?.toIso8601String(),
        "acceptedAt": acceptedAt,
        "declinedAt": declinedAt,
        "firstPaidAt": firstPaidAt,
        "fullyPaidAt": fullyPaidAt,
        "reminderCount": reminderCount,
        "lastRemindedAt": lastRemindedAt,
        "note": note,
    };
}

class Pagination {
    int? page;
    int? total;
    int? totalPages;

    Pagination({
        this.page,
        this.total,
        this.totalPages,
    });

    factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"],
        total: json["total"],
        totalPages: json["totalPages"],
    );

    Map<String, dynamic> toJson() => {
        "page": page,
        "total": total,
        "totalPages": totalPages,
    };
}
