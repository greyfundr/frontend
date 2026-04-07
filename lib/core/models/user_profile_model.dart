// To parse this JSON data, do
//
//     final userProfileModel = userProfileModelFromJson(jsonString);

import 'dart:convert';

UserProfileModel userProfileModelFromJson(String str) =>
    UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) =>
    json.encode(data.toJson());

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
  Profile? profile;
  List<Kyc>? kyc;
  String? image;
  String? dateOfBirth;

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
    this.passwordResetToken,
    this.passwordResetTokenExpiry,
    this.profile,
    this.kyc,
    this.image,
    this.dateOfBirth,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json["id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
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
        profile: json["profile"] == null
            ? null
            : Profile.fromJson(json["profile"]),
        kyc: json["kycs"] == null
            ? []
            : List<Kyc>.from(json["kycs"]!.map((x) => Kyc.fromJson(x))),
        image: json["image"],
        dateOfBirth: json["dateOfBirth"],
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
    "profile": profile?.toJson(),
    "kyc": kyc,
  };
}

class Kyc {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? userId;
  String? name;
  String? verificationType;
  String? idNumber;
  dynamic documentImage;
  String? status;
  dynamic rejectionReason;
  int? attemptCount;
  dynamic verifiedAt;
  dynamic rejectedAt;

  Kyc({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userId,
    this.name,
    this.verificationType,
    this.idNumber,
    this.documentImage,
    this.status,
    this.rejectionReason,
    this.attemptCount,
    this.verifiedAt,
    this.rejectedAt,
  });

  factory Kyc.fromJson(Map<String, dynamic> json) => Kyc(
    id: json["id"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    deletedAt: json["deletedAt"],
    userId: json["userId"],
    name: json["name"],
    verificationType: json["verificationType"],
    idNumber: json["idNumber"],
    documentImage: json["documentImage"],
    status: json["status"],
    rejectionReason: json["rejectionReason"],
    attemptCount: json["attemptCount"],
    verifiedAt: json["verifiedAt"],
    rejectedAt: json["rejectedAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "deletedAt": deletedAt,
    "userId": userId,
    "name": name,
    "verificationType": verificationType,
    "idNumber": idNumber,
    "documentImage": documentImage,
    "status": status,
    "rejectionReason": rejectionReason,
    "attemptCount": attemptCount,
    "verifiedAt": verifiedAt,
    "rejectedAt": rejectedAt,
  };
}

class Profile {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? bio;
  dynamic country;
  dynamic state;
  dynamic city;
  dynamic address;
  List<String>? interests;
  dynamic image;

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
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    deletedAt: json["deletedAt"],
    bio: json["bio"],
    country: json["country"],
    state: json["state"],
    city: json["city"],
    address: json["address"],
    interests: json["interests"] == null
        ? []
        : List<String>.from(json["interests"]!.map((x) => x)),
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
    "interests": interests == null
        ? []
        : List<dynamic>.from(interests!.map((x) => x)),
    "image": image,
  };
}
