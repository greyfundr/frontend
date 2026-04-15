// To parse this JSON data, do
//
//     final mySplitBillModel = mySplitBillModelFromJson(jsonString);

import 'dart:convert';

MySplitBillModel mySplitBillModelFromJson(String str) => MySplitBillModel.fromJson(json.decode(str));

String mySplitBillModelToJson(MySplitBillModel data) => json.encode(data.toJson());

class MySplitBillModel {
    List<Bill>? bills;
    int? total;
    int? page;
    int? totalPages;

    MySplitBillModel({
        this.bills,
        this.total,
        this.page,
        this.totalPages,
    });

    factory MySplitBillModel.fromJson(Map<String, dynamic> json) => MySplitBillModel(
        bills: json["bills"] == null ? [] : List<Bill>.from(json["bills"]!.map((x) => Bill.fromJson(x))),
        total: json["total"],
        page: json["page"],
        totalPages: json["totalPages"],
    );

    Map<String, dynamic> toJson() => {
        "bills": bills == null ? [] : List<dynamic>.from(bills!.map((x) => x.toJson())),
        "total": total,
        "page": page,
        "totalPages": totalPages,
    };
}

class Bill {
    String? id;
    String? title;
    String? description;
    String? imageUrl;
    String? billReceipt;
    int? totalAmount;
    int? totalCollected;
    int? remainingAmount;
    int? fundingPercentage;
    String? currency;
    String? splitMethod;
    String? status;
    DateTime? dueDate;
    int? totalParticipants;
    int? totalPaidParticipants;
    bool? isFinalized;
    dynamic shareLink;
    DateTime? createdAt;
    CreatedBy? createdBy;
    String? myRole;
    MyShare? myShare;
    dynamic ?minPaymentAmount;

    Bill({
        this.id,
        this.title,
        this.description,
        this.imageUrl,
        this.billReceipt,
        this.totalAmount,
        this.totalCollected,
        this.remainingAmount,
        this.fundingPercentage,
        this.currency,
        this.splitMethod,
        this.status,
        this.dueDate,
        this.totalParticipants,
        this.totalPaidParticipants,
        this.isFinalized,
        this.shareLink,
        this.createdAt,
        this.createdBy,
        this.myRole,
        this.myShare,
        this.minPaymentAmount
    });

    factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        billReceipt: json["billReceipt"],
        totalAmount: json["totalAmount"],
        totalCollected: json["totalCollected"],
        remainingAmount: json["remainingAmount"],
        fundingPercentage: json["fundingPercentage"],
        currency: json["currency"],
        splitMethod: json["splitMethod"],
        status: json["status"],
        dueDate: json["dueDate"] == null ? null : DateTime.parse(json["dueDate"]),
        totalParticipants: json["totalParticipants"],
        totalPaidParticipants: json["totalPaidParticipants"],
        isFinalized: json["isFinalized"],
        shareLink: json["shareLink"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        createdBy: json["createdBy"] == null ? null : CreatedBy.fromJson(json["createdBy"]),
        myRole: json["myRole"],
        myShare: json["myShare"] == null ? null : MyShare.fromJson(json["myShare"]),
        minPaymentAmount: json["minPaymentAmount"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "billReceipt": billReceipt,
        "totalAmount": totalAmount,
        "totalCollected": totalCollected,
        "remainingAmount": remainingAmount,
        "fundingPercentage": fundingPercentage,
        "currency": currency,
        "splitMethod": splitMethod,
        "status": status,
        "dueDate": dueDate?.toIso8601String(),
        "totalParticipants": totalParticipants,
        "totalPaidParticipants": totalPaidParticipants,
        "isFinalized": isFinalized,
        "shareLink": shareLink,
        "createdAt": createdAt?.toIso8601String(),
        "createdBy": createdBy?.toJson(),
        "myRole": myRole,
        "myShare": myShare?.toJson(),
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

class MyShare {
    String? participantId;
    String? role;
    String? status;
    dynamic amountOwed;
    dynamic amountPaid;
    dynamic amountRemaining;
    dynamic percentage;
    String? inviteCode;
    dynamic paymentLink;
    dynamic acceptedAt;
    dynamic fullyPaidAt;

    MyShare({
        this.participantId,
        this.role,
        this.status,
        this.amountOwed,
        this.amountPaid,
        this.amountRemaining,
        this.percentage,
        this.inviteCode,
        this.paymentLink,
        this.acceptedAt,
        this.fullyPaidAt,
    });

    factory MyShare.fromJson(Map<String, dynamic> json) => MyShare(
        participantId: json["participantId"],
        role: json["role"],
        status: json["status"],
        amountOwed: json["amountOwed"],
        amountPaid: json["amountPaid"],
        amountRemaining: json["amountRemaining"],
        percentage: json["percentage"],
        inviteCode: json["inviteCode"],
        paymentLink: json["paymentLink"],
        acceptedAt: json["acceptedAt"],
        fullyPaidAt: json["fullyPaidAt"],
    );

    Map<String, dynamic> toJson() => {
        "participantId": participantId,
        "role": role,
        "status": status,
        "amountOwed": amountOwed,
        "amountPaid": amountPaid,
        "amountRemaining": amountRemaining,
        "percentage": percentage,
        "inviteCode": inviteCode,
        "paymentLink": paymentLink,
        "acceptedAt": acceptedAt,
        "fullyPaidAt": fullyPaidAt,
    };
}
