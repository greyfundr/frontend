// To parse this JSON data, do
//
//     final campaignDetailsModel = campaignDetailsModelFromJson(jsonString);

import 'dart:convert';

CampaignDetailsModel campaignDetailsModelFromJson(String str) => CampaignDetailsModel.fromJson(json.decode(str));

String campaignDetailsModelToJson(CampaignDetailsModel data) => json.encode(data.toJson());

class CampaignDetailsModel {
    String? id;
    String? title;
    String? description;
    int? target;
    int? currentAmount;
    DateTime? startDate;
    DateTime? endDate;
    List<Offer>? offers;
    List<Budget>? budget;
    List<Image>? images;
    String? status;
    List<Creator>? participants;
    String? shareSlug;
    String? shareUrl;
    Creator? creator;
    DateTime? createdAt;
    int? likesCount;
    int? commentsCount;
    bool? isLiked;

    CampaignDetailsModel({
        this.id,
        this.title,
        this.description,
        this.target,
        this.currentAmount,
        this.startDate,
        this.endDate,
        this.offers,
        this.budget,
        this.images,
        this.status,
        this.participants,
        this.shareSlug,
        this.shareUrl,
        this.creator,
        this.createdAt,
        this.likesCount,
        this.commentsCount,
        this.isLiked,
    });

    factory CampaignDetailsModel.fromJson(Map<String, dynamic> json) => CampaignDetailsModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        target: json["target"],
        currentAmount: json["currentAmount"],
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        offers: json["offers"] == null ? [] : List<Offer>.from(json["offers"]!.map((x) => Offer.fromJson(x))),
        budget: json["budget"] == null ? [] : List<Budget>.from(json["budget"]!.map((x) => Budget.fromJson(x))),
        images: json["images"] == null ? [] : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x))),
        status: json["status"],
        participants: json["participants"] == null ? [] : List<Creator>.from(json["participants"]!.map((x) => Creator.fromJson(x))),
        shareSlug: json["shareSlug"],
        shareUrl: json["shareUrl"],
        creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        likesCount: json["likesCount"],
        commentsCount: json["commentsCount"],
        isLiked: json["isLiked"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "target": target,
        "currentAmount": currentAmount,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "offers": offers == null ? [] : List<dynamic>.from(offers!.map((x) => x.toJson())),
        "budget": budget == null ? [] : List<dynamic>.from(budget!.map((x) => x.toJson())),
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
        "status": status,
        "participants": participants == null ? [] : List<dynamic>.from(participants!.map((x) => x.toJson())),
        "shareSlug": shareSlug,
        "shareUrl": shareUrl,
        "creator": creator?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "likesCount": likesCount,
        "commentsCount": commentsCount,
        "isLiked": isLiked,
    };
}

class Budget {
    int? cost;
    String? item;
    String? image;

    Budget({
        this.cost,
        this.item,
        this.image,
    });

    factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        cost: json["cost"],
        item: json["item"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "cost": cost,
        "item": item,
        "image": image,
    };
}

class Creator {
    String? id;
    String? firstName;
    String? lastName;
    String? username;
    String? profileImage;

    Creator({
        this.id,
        this.firstName,
        this.lastName,
        this.username,
        this.profileImage,
    });

    factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        username: json["username"],
        profileImage: json["profileImage"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
        "profileImage": profileImage,
    };
}

class Image {
    String? imageUrl;
    String? providerId;

    Image({
        this.imageUrl,
        this.providerId,
    });

    factory Image.fromJson(Map<String, dynamic> json) => Image(
        imageUrl: json["imageUrl"],
        providerId: json["providerId"],
    );

    Map<String, dynamic> toJson() => {
        "imageUrl": imageUrl,
        "providerId": providerId,
    };
}

class Offer {
    String? type;
    String? reward;
    String? condition;

    Offer({
        this.type,
        this.reward,
        this.condition,
    });

    factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        type: json["type"],
        reward: json["reward"],
        condition: json["condition"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "reward": reward,
        "condition": condition,
    };
}
