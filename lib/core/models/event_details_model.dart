// To parse this JSON data, do
//
//     final eventDetailsModel = eventDetailsModelFromJson(jsonString);

import 'dart:convert';

EventDetailsModel eventDetailsModelFromJson(String str) =>
    EventDetailsModel.fromJson(json.decode(str));

String eventDetailsModelToJson(EventDetailsModel data) =>
    json.encode(data.toJson());

class EventDetailsModel {
  List<String>? coverImages;
  List<dynamic>? purchasableItems;
  List<Activity>? activities;
  List<dynamic>? externalOrganizers;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? name;
  dynamic title;
  String? shortDescription;
  List<DetailedDescription>? detailedDescription;
  String? categoryId;
  Location? location;
  String? hashtag;
  int? targetAmount;
  int? amountRaised;
  bool? acceptDonations;
  bool? hideDonationAmount;
  DateTime? startDateTime;
  dynamic endDateTime;
  DateTime? startTime;
  dynamic qrCodeLink;
  int? expectedParticipants;
  String? venueName;
  String? creatorId;
  String? status;
  int? pageNumber;
  bool? isApproved;
  dynamic rejectionReason;
  String? visibilityStatus;
  bool? isPublished;
  String? shareLink;
  Category? category;
  Creator? creator;
  List<Organizer>? organizers;

  EventDetailsModel({
    this.coverImages,
    this.purchasableItems,
    this.activities,
    this.externalOrganizers,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.name,
    this.title,
    this.shortDescription,
    this.detailedDescription,
    this.categoryId,
    this.location,
    this.hashtag,
    this.targetAmount,
    this.amountRaised,
    this.acceptDonations,
    this.hideDonationAmount,
    this.startDateTime,
    this.endDateTime,
    this.startTime,
    this.qrCodeLink,
    this.expectedParticipants,
    this.venueName,
    this.creatorId,
    this.status,
    this.pageNumber,
    this.isApproved,
    this.rejectionReason,
    this.visibilityStatus,
    this.isPublished,
    this.shareLink,
    this.category,
    this.creator,
    this.organizers,
  });

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) =>
      EventDetailsModel(
        coverImages: json["coverImages"] == null
            ? []
            : List<String>.from(json["coverImages"]!.map((x) => x)),
        purchasableItems: json["purchasableItems"] == null
            ? []
            : List<dynamic>.from(json["purchasableItems"]!.map((x) => x)),
        activities: json["activities"] == null
            ? []
            : List<Activity>.from(
                json["activities"]!.map((x) => Activity.fromJson(x)),
              ),
        externalOrganizers: json["externalOrganizers"] == null
            ? []
            : List<dynamic>.from(json["externalOrganizers"]!.map((x) => x)),
        id: json["id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        name: json["name"],
        title: json["title"],
        shortDescription: json["shortDescription"],
        detailedDescription: json["detailedDescription"] == null
            ? []
            : List<DetailedDescription>.from(
                json["detailedDescription"]!.map(
                  (x) => DetailedDescription.fromJson(x),
                ),
              ),
        categoryId: json["categoryId"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        hashtag: json["hashtag"],
        targetAmount: json["targetAmount"],
        amountRaised: json["amountRaised"],
        acceptDonations: json["acceptDonations"],
        hideDonationAmount: json["hideDonationAmount"],
        startDateTime: json["startDateTime"] == null
            ? null
            : DateTime.parse(json["startDateTime"]),
        endDateTime: json["endDateTime"],
        startTime: json["startTime"] == null
            ? null
            : DateTime.parse(json["startTime"]),
        qrCodeLink: json["qrCodeLink"],
        expectedParticipants: json["expectedParticipants"],
        venueName: json["venueName"],
        creatorId: json["creatorId"],
        status: json["status"],
        pageNumber: json["pageNumber"],
        isApproved: json["isApproved"],
        rejectionReason: json["rejectionReason"],
        visibilityStatus: json["visibilityStatus"],
        isPublished: json["isPublished"],
        shareLink: json["shareLink"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        creator: json["creator"] == null
            ? null
            : Creator.fromJson(json["creator"]),
        organizers: json["organizers"] == null
            ? []
            : List<Organizer>.from(
                json["organizers"]!.map((x) => Organizer.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "coverImages": coverImages == null
        ? []
        : List<dynamic>.from(coverImages!.map((x) => x)),
    "purchasableItems": purchasableItems == null
        ? []
        : List<dynamic>.from(purchasableItems!.map((x) => x)),
    "externalOrganizers": externalOrganizers == null
        ? []
        : List<dynamic>.from(externalOrganizers!.map((x) => x)),
    "id": id,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "deletedAt": deletedAt,
    "name": name,
    "title": title,
    "shortDescription": shortDescription,
    "detailedDescription": detailedDescription == null
        ? []
        : List<dynamic>.from(detailedDescription!.map((x) => x.toJson())),
    "categoryId": categoryId,
    "location": location?.toJson(),
    "hashtag": hashtag,
    "targetAmount": targetAmount,
    "amountRaised": amountRaised,
    "acceptDonations": acceptDonations,
    "hideDonationAmount": hideDonationAmount,
    "startDateTime": startDateTime?.toIso8601String(),
    "endDateTime": endDateTime,
    "startTime": startTime?.toIso8601String(),
    "qrCodeLink": qrCodeLink,
    "expectedParticipants": expectedParticipants,
    "venueName": venueName,
    "creatorId": creatorId,
    "status": status,
    "pageNumber": pageNumber,
    "isApproved": isApproved,
    "rejectionReason": rejectionReason,
    "visibilityStatus": visibilityStatus,
    "isPublished": isPublished,
    "shareLink": shareLink,
    "category": category?.toJson(),
    "creator": creator?.toJson(),
    "organizers": organizers == null
        ? []
        : List<dynamic>.from(organizers!.map((x) => x.toJson())),
  };
}

class Activity {
  String? name;
  DateTime? time;
  String? image;
  String? description;
  int? targetAmount;

  Activity({
    this.name,
    this.time,
    this.image,
    this.description,
    this.targetAmount,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    name: json["name"],
    time: json["time"] == null ? null : DateTime.parse(json["time"]),
    image: json["image"],
    description: json["description"],
    targetAmount: json["targetAmount"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "time": time?.toIso8601String(),
    "image": image,
    "description": description,
    "targetAmount": targetAmount,
  };
}

class Category {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? name;
  dynamic icon;
  bool? isActive;

  Category({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.name,
    this.icon,
    this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    deletedAt: json["deletedAt"],
    name: json["name"],
    icon: json["icon"],
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "deletedAt": deletedAt,
    "name": name,
    "icon": icon,
    "isActive": isActive,
  };
}

class Creator {
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
  dynamic dateOfBirth;

  Creator({
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
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
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
    "dateOfBirth": dateOfBirth,
  };
}

class DetailedDescription {
  String? text;
  List<String>? media;
  String? title;

  DetailedDescription({this.text, this.media, this.title});

  factory DetailedDescription.fromJson(Map<String, dynamic> json) =>
      DetailedDescription(
        text: json["text"],
        media: json["media"] == null
            ? []
            : List<String>.from(json["media"]!.map((x) => x)),
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
    "text": text,
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x)),
    "title": title,
  };
}

class Location {
  int? lat;
  double? lng;
  String? address;
  String? venueName;
  String? locationDescription;

  Location({
    this.lat,
    this.lng,
    this.address,
    this.venueName,
    this.locationDescription,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"],
    lng: json["lng"]?.toDouble(),
    address: json["address"],
    venueName: json["venueName"],
    locationDescription: json["locationDescription"],
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
    "address": address,
    "venueName": venueName,
    "locationDescription": locationDescription,
  };
}

class Organizer {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? eventId;
  String? userId;
  String? role;
  Creator? user;

  Organizer({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.eventId,
    this.userId,
    this.role,
    this.user,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) => Organizer(
    id: json["id"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    deletedAt: json["deletedAt"],
    eventId: json["eventId"],
    userId: json["userId"],
    role: json["role"],
    user: json["user"] == null ? null : Creator.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "deletedAt": deletedAt,
    "eventId": eventId,
    "userId": userId,
    "role": role,
    "user": user?.toJson(),
  };
}
