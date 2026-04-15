// To parse this JSON data, do
//
//     final allUsersModel = allUsersModelFromJson(jsonString);

import 'dart:convert';

List<AllUsersModel> allUsersModelFromJson(String str) => List<AllUsersModel>.from(json.decode(str).map((x) => AllUsersModel.fromJson(x)));

String allUsersModelToJson(List<AllUsersModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllUsersModel {
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
    DateTime? dateOfBirth;
    String? bvn;
    Profile? profile;
    List<dynamic>? kycs;

    AllUsersModel({
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
        this.dateOfBirth,
        this.bvn,
        this.profile,
        this.kycs,
    });

    factory AllUsersModel.fromJson(Map<String, dynamic> json) => AllUsersModel(
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
        dateOfBirth: json["dateOfBirth"] == null ? null : DateTime.parse(json["dateOfBirth"]),
        bvn: json["bvn"],
        profile: json["profile"] == null ? null : Profile.fromJson(json["profile"]),
        kycs: json["kycs"] == null ? [] : List<dynamic>.from(json["kycs"]!.map((x) => x)),
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
        "dateOfBirth": "${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}",
        "bvn": bvn,
        "profile": profile?.toJson(),
        "kycs": kycs == null ? [] : List<dynamic>.from(kycs!.map((x) => x)),
    };
}

class Profile {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    dynamic bio;
    dynamic country;
    dynamic state;
    dynamic city;
    dynamic address;
    List<dynamic>? interests;
    String? image;

    Profile({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.bio,
        this.country,
        this.state,
        this.city,
        this.address,
        this.interests,
        this.image,
    });

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        bio: json["bio"],
        country: json["country"],
        state: json["state"],
        city: json["city"],
        address: json["address"],
        interests: json["interests"] == null ? [] : List<dynamic>.from(json["interests"]!.map((x) => x)),
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "bio": bio,
        "country": country,
        "state": state,
        "city": city,
        "address": address,
        "interests": interests == null ? [] : List<dynamic>.from(interests!.map((x) => x)),
        "image": image,
    };
}
