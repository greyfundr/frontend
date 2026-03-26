// To parse this JSON data, do
//
//     final allEventModel = allEventModelFromJson(jsonString);

import 'dart:convert';

List<AllEventModel> allEventModelFromJson(String str) => List<AllEventModel>.from(json.decode(str).map((x) => AllEventModel.fromJson(x)));

String allEventModelToJson(List<AllEventModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllEventModel {
    List<String>? coverImages;
    List<PurchasableItem>? purchasableItems;
    List<Activity>? activities;
    List<ExternalOrganizer>? externalOrganizers;
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
    Category? category;
    Creator? creator;

    AllEventModel({
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
        this.category,
        this.creator,
    });

    factory AllEventModel.fromJson(Map<String, dynamic> json) => AllEventModel(
        coverImages: json["coverImages"] == null ? [] : List<String>.from(json["coverImages"]!.map((x) => x)),
        purchasableItems: json["purchasableItems"] == null ? [] : List<PurchasableItem>.from(json["purchasableItems"]!.map((x) => PurchasableItem.fromJson(x))),
        activities: json["activities"] == null ? [] : List<Activity>.from(json["activities"]!.map((x) => Activity.fromJson(x))),
        externalOrganizers: json["externalOrganizers"] == null ? [] : List<ExternalOrganizer>.from(json["externalOrganizers"]!.map((x) => ExternalOrganizer.fromJson(x))),
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        name: json["name"],
        title: json["title"],
        shortDescription: json["shortDescription"],
        detailedDescription: json["detailedDescription"] == null ? [] : List<DetailedDescription>.from(json["detailedDescription"]!.map((x) => DetailedDescription.fromJson(x))),
        categoryId: json["categoryId"],
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        hashtag: json["hashtag"],
        targetAmount: json["targetAmount"],
        amountRaised: json["amountRaised"],
        acceptDonations: json["acceptDonations"],
        startDateTime: json["startDateTime"] == null ? null : DateTime.parse(json["startDateTime"]),
        endDateTime: json["endDateTime"] == null ? null : DateTime.parse(json["endDateTime"]),
        startTime: json["startTime"],
        qrCodeLink: json["qrCodeLink"],
        expectedParticipants: json["expectedParticipants"],
        venueName: json["venueName"],
        creatorId: json["creatorId"],
        status: json["status"],
        category: json["category"] == null ? null : Category.fromJson(json["category"]),
        creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
    );

    Map<String, dynamic> toJson() => {
        "coverImages": coverImages == null ? [] : List<dynamic>.from(coverImages!.map((x) => x)),
        "purchasableItems": purchasableItems == null ? [] : List<dynamic>.from(purchasableItems!.map((x) => x.toJson())),
        "activities": activities == null ? [] : List<dynamic>.from(activities!.map((x) => x.toJson())),
        "externalOrganizers": externalOrganizers == null ? [] : List<dynamic>.from(externalOrganizers!.map((x) => x.toJson())),
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "name": name,
        "title": title,
        "shortDescription": shortDescription,
        "detailedDescription": detailedDescription == null ? [] : List<dynamic>.from(detailedDescription!.map((x) => x.toJson())),
        "categoryId": categoryId,
        "location": location?.toJson(),
        "hashtag": hashtag,
        "targetAmount": targetAmount,
        "amountRaised": amountRaised,
        "acceptDonations": acceptDonations,
        "startDateTime": startDateTime?.toIso8601String(),
        "endDateTime": endDateTime?.toIso8601String(),
        "startTime": startTime,
        "qrCodeLink": qrCodeLink,
        "expectedParticipants": expectedParticipants,
        "venueName": venueName,
        "creatorId": creatorId,
        "status": status,
        "category": category?.toJson(),
        "creator": creator?.toJson(),
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
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
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

    DetailedDescription({
        this.text,
        this.media,
    });

    factory DetailedDescription.fromJson(Map<String, dynamic> json) => DetailedDescription(
        text: json["text"],
        media: json["media"] == null ? [] : List<String>.from(json["media"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "text": text,
        "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x)),
    };
}

class ExternalOrganizer {
    String? name;
    String? number;

    ExternalOrganizer({
        this.name,
        this.number,
    });

    factory ExternalOrganizer.fromJson(Map<String, dynamic> json) => ExternalOrganizer(
        name: json["name"],
        number: json["number"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "number": number,
    };
}

class Location {
    double? lat;
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
        lat: json["lat"]?.toDouble(),
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

class PurchasableItem {
    String? name;
    int? price;
    List<String>? images;
    int? quantity;

    PurchasableItem({
        this.name,
        this.price,
        this.images,
        this.quantity,
    });

    factory PurchasableItem.fromJson(Map<String, dynamic> json) => PurchasableItem(
        name: json["name"],
        price: json["price"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        quantity: json["quantity"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "quantity": quantity,
    };
}
