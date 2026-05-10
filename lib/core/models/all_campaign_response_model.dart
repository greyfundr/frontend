// To parse this JSON data, do
//
//     final allCampaignResponseModel = allCampaignResponseModelFromJson(jsonString);

import 'dart:convert';

AllCampaignResponseModel allCampaignResponseModelFromJson(String str) => AllCampaignResponseModel.fromJson(json.decode(str));

String allCampaignResponseModelToJson(AllCampaignResponseModel data) => json.encode(data.toJson());

class AllCampaignResponseModel {
    List<CampaignDatum>? data;
    Pagination? pagination;

    AllCampaignResponseModel({
        this.data,
        this.pagination,
    });

    factory AllCampaignResponseModel.fromJson(Map<String, dynamic> json) => AllCampaignResponseModel(
        data: json["data"] == null ? [] : List<CampaignDatum>.from(json["data"]!.map((x) => CampaignDatum.fromJson(x))),
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
    };
}

class CampaignDatum {
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
    Status? status;
    String? shareSlug;
    String? shareUrl;
    Creator? creator;
    DateTime? createdAt;
    int? donorsCount;
    int ? likesCount;

    CampaignDatum({
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
        this.shareSlug,
        this.shareUrl,
        this.creator,
        this.createdAt,
        this.donorsCount = 0,
        this.likesCount = 0,
    });

    factory CampaignDatum.fromJson(Map<String, dynamic> json) => CampaignDatum(
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
        status: statusValues.map[json["status"]]!,
        shareSlug: json["shareSlug"],
        shareUrl: json["shareUrl"],
        creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        donorsCount: json["donorsCount"] ?? 0,
        likesCount: json["likesCount"] ?? 0,
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
        "status": statusValues.reverse[status],
        "shareSlug": shareSlug,
        "shareUrl": shareUrl,
        "creator": creator?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
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

enum Status {
    ACTIVE
}

final statusValues = EnumValues({
    "active": Status.ACTIVE
});

class Pagination {
    int? page;
    int? limit;
    int? total;
    int? totalPages;
    bool? hasNext;
    bool? hasPrevious;

    Pagination({
        this.page,
        this.limit,
        this.total,
        this.totalPages,
        this.hasNext,
        this.hasPrevious,
    });

    factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
        totalPages: json["totalPages"],
        hasNext: json["hasNext"],
        hasPrevious: json["hasPrevious"],
    );

    Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "totalPages": totalPages,
        "hasNext": hasNext,
        "hasPrevious": hasPrevious,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
