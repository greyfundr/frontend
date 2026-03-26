// To parse this JSON data, do
//
//     final singleSplitBillModel = singleSplitBillModelFromJson(jsonString);

import 'dart:convert';

SingleSplitBillModel singleSplitBillModelFromJson(String str) => SingleSplitBillModel.fromJson(json.decode(str));

String singleSplitBillModelToJson(SingleSplitBillModel data) => json.encode(data.toJson());

class SingleSplitBillModel {
    bool? success;
    String? message;
    Data? data;

    SingleSplitBillModel({
        this.success,
        this.message,
        this.data,
    });

    factory SingleSplitBillModel.fromJson(Map<String, dynamic> json) => SingleSplitBillModel(
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
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    String? title;
    String? description;
    String? imageUrl;
    dynamic billReceipt;
    int? totalAmount;
    int? totalCollected;
    String? currency;
    String? splitMethod;
    bool? isFinalized;
    dynamic finalizedAt;
    bool? allowPartialPayment;
    int? minPaymentAmount;
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

    Data({
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

    factory Data.fromJson(Map<String, dynamic> json) => Data(
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
    String?  guestName;
    dynamic guestPhone;
    dynamic guestEmail;
    String? role;
    int? amountOwed;
    int? amountPaid;
    int? amountRemaining;
    int? balanceAdjustment;
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
    User? user;

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
        this.user,
    });

    factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        splitBillId: json["splitBillId"],
        userId: json["userId"],
        guestName: json["guestName"] ?? "",
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
        user: json["user"] == null ? null : User.fromJson(json["user"]),
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
        "user": user?.toJson(),
    };
}

class User {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    String? email;
    String? phoneNumber;
    String? password;
    String? firstName;
    String? lastName;
    String? username;
    String? accountType;
    String? emailOtp;
    String? phoneOtp;
    bool? hasVerifiedPhone;
    dynamic otpExpiration;
    bool? hasSubmittedBasicInfo;
    bool? hasCompletedKyc;
    bool? agreeToTerms;
    dynamic cacNumber;
    dynamic companyName;
    dynamic tin;
    String? refreshToken;
    String? pin;
    dynamic passwordResetToken;
    dynamic passwordResetTokenExpiry;

    User({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.email,
        this.phoneNumber,
        this.password,
        this.firstName,
        this.lastName,
        this.username,
        this.accountType,
        this.emailOtp,
        this.phoneOtp,
        this.hasVerifiedPhone,
        this.otpExpiration,
        this.hasSubmittedBasicInfo,
        this.hasCompletedKyc,
        this.agreeToTerms,
        this.cacNumber,
        this.companyName,
        this.tin,
        this.refreshToken,
        this.pin,
        this.passwordResetToken,
        this.passwordResetTokenExpiry,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        password: json["password"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        username: json["username"],
        accountType: json["accountType"],
        emailOtp: json["emailOtp"],
        phoneOtp: json["phoneOtp"],
        hasVerifiedPhone: json["hasVerifiedPhone"],
        otpExpiration: json["otpExpiration"],
        hasSubmittedBasicInfo: json["hasSubmittedBasicInfo"],
        hasCompletedKyc: json["hasCompletedKyc"],
        agreeToTerms: json["agreeToTerms"],
        cacNumber: json["cacNumber"],
        companyName: json["companyName"],
        tin: json["tin"],
        refreshToken: json["refreshToken"],
        pin: json["pin"],
        passwordResetToken: json["passwordResetToken"],
        passwordResetTokenExpiry: json["passwordResetTokenExpiry"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "email": email,
        "phoneNumber": phoneNumber,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
        "accountType": accountType,
        "emailOtp": emailOtp,
        "phoneOtp": phoneOtp,
        "hasVerifiedPhone": hasVerifiedPhone,
        "otpExpiration": otpExpiration,
        "hasSubmittedBasicInfo": hasSubmittedBasicInfo,
        "hasCompletedKyc": hasCompletedKyc,
        "agreeToTerms": agreeToTerms,
        "cacNumber": cacNumber,
        "companyName": companyName,
        "tin": tin,
        "refreshToken": refreshToken,
        "pin": pin,
        "passwordResetToken": passwordResetToken,
        "passwordResetTokenExpiry": passwordResetTokenExpiry,
    };
}
