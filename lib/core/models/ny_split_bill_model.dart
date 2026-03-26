import 'dart:convert';

MySplitBillModel mySplitBillModelFromJson(String str) => MySplitBillModel.fromJson(json.decode(str));

String mySplitBillModelToJson(MySplitBillModel data) => json.encode(data.toJson());

class MySplitBillModel {
    bool? success;
    String? message;
    Data? data;

    MySplitBillModel({
        this.success,
        this.message,
        this.data,
    });

    factory MySplitBillModel.fromJson(Map<String, dynamic> json) => MySplitBillModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    List<Bill>? bills;
    int? total;
    int? page;
    int? totalPages;

    Data({
        this.bills,
        this.total,
        this.page,
        this.totalPages,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
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
    String? currency;
    String? splitMethod;
    String? status;
    DateTime? dueDate;
    int? totalParticipants;
    int? totalPaidParticipants;
    bool? isFinalized;
    String? creatorId;
    String? creatorName;
    String? visibility;
    DateTime? createdAt;
    MyShare? myShare;

    Bill({
        this.id,
        this.title,
        this.description,
        this.imageUrl,
        this.billReceipt,
        this.totalAmount,
        this.totalCollected,
        this.currency,
        this.splitMethod,
        this.status,
        this.dueDate,
        this.totalParticipants,
        this.totalPaidParticipants,
        this.isFinalized,
        this.creatorId,
        this.creatorName,
        this.visibility,
        this.createdAt,
        this.myShare,
    });

    factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        billReceipt: json["billReceipt"],
        totalAmount: json["totalAmount"],
        totalCollected: json["totalCollected"],
        currency: json["currency"],
        splitMethod: json["splitMethod"],
        status: json["status"],
        dueDate: json["dueDate"] == null ? null : DateTime.parse(json["dueDate"]),
        totalParticipants: json["totalParticipants"],
        totalPaidParticipants: json["totalPaidParticipants"],
        isFinalized: json["isFinalized"],
        creatorId: json["creatorId"],
        creatorName: json["creatorName"],
        visibility: json["visibility"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        myShare: json["myShare"] == null ? null : MyShare.fromJson(json["myShare"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "billReceipt": billReceipt,
        "totalAmount": totalAmount,
        "totalCollected": totalCollected,
        "currency": currency,
        "splitMethod": splitMethod,
        "status": status,
        "dueDate": dueDate?.toIso8601String(),
        "totalParticipants": totalParticipants,
        "totalPaidParticipants": totalPaidParticipants,
        "isFinalized": isFinalized,
        "creatorId": creatorId,
        "creatorName": creatorName,
        "visibility": visibility,
        "createdAt": createdAt?.toIso8601String(),
        "myShare": myShare?.toJson(),
    };
}

class MyShare {
    String? participantId;
    String? role;
    int? amountOwed;
    int? amountPaid;
    int? amountRemaining;
    String? status;
    String? inviteCode;
    dynamic paymentLink;

    MyShare({
        this.participantId,
        this.role,
        this.amountOwed,
        this.amountPaid,
        this.amountRemaining,
        this.status,
        this.inviteCode,
        this.paymentLink,
    });

    factory MyShare.fromJson(Map<String, dynamic> json) => MyShare(
        participantId: json["participantId"],
        role: json["role"],
        amountOwed: json["amountOwed"],
        amountPaid: json["amountPaid"],
        amountRemaining: json["amountRemaining"],
        status: json["status"],
        inviteCode: json["inviteCode"],
        paymentLink: json["paymentLink"],
    );

    Map<String, dynamic> toJson() => {
        "participantId": participantId,
        "role": role,
        "amountOwed": amountOwed,
        "amountPaid": amountPaid,
        "amountRemaining": amountRemaining,
        "status": status,
        "inviteCode": inviteCode,
        "paymentLink": paymentLink,
    };
}