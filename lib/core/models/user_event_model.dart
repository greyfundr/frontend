// To parse this JSON data, do
//
//     final allEventModel = allEventModelFromJson(jsonString);

import 'dart:convert';

AllEventModel allEventModelFromJson(String str) =>
    AllEventModel.fromJson(json.decode(str));

String allEventModelToJson(AllEventModel data) => json.encode(data.toJson());

class AllEventModel {
  List<EventDatum>? events;
  int? total;
  int? page;
  int? totalPages;

  AllEventModel({this.events, this.total, this.page, this.totalPages});

  factory AllEventModel.fromJson(Map<String, dynamic> json) => AllEventModel(
    events: json["events"] == null
        ? []
        : List<EventDatum>.from(
            json["events"]!.map((x) => EventDatum.fromJson(x)),
          ),
    total: json["total"],
    page: json["page"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "events": events == null
        ? []
        : List<dynamic>.from(events!.map((x) => x.toJson())),
    "total": total,
    "page": page,
    "totalPages": totalPages,
  };
}

class EventDatum {
  List<String>? coverImages;
  List<dynamic>? purchasableItems;
  List<dynamic>? activities;
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
  DateTime? startDateTime;
  DateTime? endDateTime;
  String? startTime;
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
  dynamic shareLink;
  Category? category;
  Creator? creator;
  String? creatorName;

  EventDatum({
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
    this.creatorName,
  });

  factory EventDatum.fromJson(Map<String, dynamic> json) => EventDatum(
    coverImages: json["coverImages"] == null
        ? []
        : List<String>.from(json["coverImages"]!.map((x) => x)),
    purchasableItems: json["purchasableItems"] == null
        ? []
        : List<dynamic>.from(json["purchasableItems"]!.map((x) => x)),
    activities: json["activities"] == null
        ? []
        : List<dynamic>.from(json["activities"]!.map((x) => x)),
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
    startDateTime: json["startDateTime"] == null
        ? null
        : DateTime.parse(json["startDateTime"]),
    endDateTime: json["endDateTime"] == null
        ? null
        : DateTime.parse(json["endDateTime"]),
    startTime: json["startTime"],
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
    creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
    creatorName: json["creatorName"],
  );

  Map<String, dynamic> toJson() => {
    "coverImages": coverImages == null
        ? []
        : List<dynamic>.from(coverImages!.map((x) => x)),
    "purchasableItems": purchasableItems == null
        ? []
        : List<dynamic>.from(purchasableItems!.map((x) => x)),
    "activities": activities == null
        ? []
        : List<dynamic>.from(activities!.map((x) => x)),
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
    "startDateTime": startDateTime?.toIso8601String(),
    "endDateTime": endDateTime,
    "startTime": startTime,
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
    "creatorName": creatorName,
  };
}

class Category {
  String? name;

  Category({this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(name: json["name"]);

  Map<String, dynamic> toJson() => {"name": name};
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
  String? refreshToken;
  String? pin;

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
    this.refreshToken,
    this.pin,
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
    "refreshToken": refreshToken,
    "pin": pin,
  };
}

class DetailedDescription {
  String? text;
  String? title;
  List<String>? media;

  DetailedDescription({this.text, this.media, this.title});

  factory DetailedDescription.fromJson(Map<String, dynamic> json) =>
      DetailedDescription(
        text: json["text"],
        title: json["title"],
        media: json["media"] == null
            ? []
            : List<String>.from(json["media"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "text": text,
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x)),
  };
}

class Location {
  dynamic? lat;
  dynamic? lng;
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
