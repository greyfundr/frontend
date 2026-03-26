// To parse this JSON data, do
//
//     final userSearchModel = userSearchModelFromJson(jsonString);

import 'dart:convert';

List<UserSearchModel> userSearchModelFromJson(String str) => List<UserSearchModel>.from(json.decode(str).map((x) => UserSearchModel.fromJson(x)));

String userSearchModelToJson(List<UserSearchModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserSearchModel {
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
    dynamic dateOfBirth;
    dynamic profile;
    dynamic kyc;

    UserSearchModel({
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
        this.dateOfBirth,
        this.profile,
        this.kyc,
    });

    factory UserSearchModel.fromJson(Map<String, dynamic> json) => UserSearchModel(
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
        dateOfBirth: json["dateOfBirth"],
        profile: json["profile"],
        kyc: json["kyc"],
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
        "dateOfBirth": dateOfBirth,
        "profile": profile,
        "kyc": kyc,
    };
}
