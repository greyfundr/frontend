// To parse this JSON data, do
//
//     final campaignDonationsResponseModel = campaignDonationsResponseModelFromJson(jsonString);

import 'dart:convert';

CampaignDonationsResponseModel campaignDonationsResponseModelFromJson(String str) =>
    CampaignDonationsResponseModel.fromJson(json.decode(str));

String campaignDonationsResponseModelToJson(CampaignDonationsResponseModel data) =>
    json.encode(data.toJson());

class CampaignDonationsResponseModel {
  List<DonationDatum>? data;
  DonationsPagination? pagination;

  CampaignDonationsResponseModel({
    this.data,
    this.pagination,
  });

  factory CampaignDonationsResponseModel.fromJson(Map<String, dynamic> json) =>
      CampaignDonationsResponseModel(
        data: json["data"] == null
            ? []
            : List<DonationDatum>.from(
                json["data"]!.map((x) => DonationDatum.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : DonationsPagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class DonationDatum {
  String? id;
  int? amount;
  bool? isAnonymous;
  String? customUsername;
  String? onBehalfOf;
  String? comment;
  Donor? donor;
  DateTime? createdAt;

  DonationDatum({
    this.id,
    this.amount,
    this.isAnonymous,
    this.customUsername,
    this.onBehalfOf,
    this.comment,
    this.donor,
    this.createdAt,
  });

  factory DonationDatum.fromJson(Map<String, dynamic> json) => DonationDatum(
        id: json["id"],
        amount: json["amount"] is int
            ? json["amount"]
            : int.tryParse(json["amount"]?.toString() ?? ''),
        isAnonymous: json["isAnonymous"],
        customUsername: json["customUsername"],
        onBehalfOf: json["onBehalfOf"],
        comment: json["comment"],
        donor: json["donor"] == null ? null : Donor.fromJson(json["donor"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "isAnonymous": isAnonymous,
        "customUsername": customUsername,
        "onBehalfOf": onBehalfOf,
        "comment": comment,
        "donor": donor?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
      };
}

class Donor {
  String? id;
  String? firstName;
  String? lastName;
  String? username;
  String? profileImage;

  Donor({
    this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.profileImage,
  });

  factory Donor.fromJson(Map<String, dynamic> json) => Donor(
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

class DonationsPagination {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  bool? hasNext;
  bool? hasPrevious;

  DonationsPagination({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNext,
    this.hasPrevious,
  });

  factory DonationsPagination.fromJson(Map<String, dynamic> json) =>
      DonationsPagination(
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
