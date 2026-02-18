// To parse this JSON data, do
//
//     final userProfileModel = userProfileModelFromJson(jsonString);

import 'dart:convert';

UserProfileModel userProfileModelFromJson(String str) => UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) => json.encode(data.toJson());

class UserProfileModel {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    String? email;
    String? phoneNumber;
    String? password;
    String? firstName;
    String? lastName;
    dynamic username;
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
    dynamic pin;

    UserProfileModel({
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
    });

    factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
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
    };
}
