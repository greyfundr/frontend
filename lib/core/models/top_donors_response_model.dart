// To parse this JSON data, do
//
//     final topDonors = topDonorsFromJson(jsonString);

import 'dart:convert';

List<TopDonor> topDonorsFromJson(String str) => List<TopDonor>.from(
    (json.decode(str) as List).map((x) => TopDonor.fromJson(x)));

String topDonorsToJson(List<TopDonor> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TopDonor {
  String? donorId;
  String? donorFirstName;
  String? donorLastName;
  String? profileImage;
  double? totalDonated;

  TopDonor({
    this.donorId,
    this.donorFirstName,
    this.donorLastName,
    this.profileImage,
    this.totalDonated,
  });

  factory TopDonor.fromJson(Map<String, dynamic> json) => TopDonor(
        donorId: json["donor_id"]?.toString(),
        donorFirstName: json["donor_first_name"]?.toString(),
        donorLastName: json["donor_last_name"]?.toString(),
        profileImage: json["profile_image"]?.toString(),
        totalDonated: json["totalDonated"] == null
            ? null
            : double.tryParse(json["totalDonated"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "donor_id": donorId,
        "donor_first_name": donorFirstName,
        "donor_last_name": donorLastName,
        "profile_image": profileImage,
        "totalDonated": totalDonated?.toStringAsFixed(2),
      };
}
