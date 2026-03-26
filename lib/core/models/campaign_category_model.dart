// To parse this JSON data, do
//
//     final campaignCategoryModel = campaignCategoryModelFromJson(jsonString);

import 'dart:convert';

List<CampaignCategoryModel> campaignCategoryModelFromJson(String str) => List<CampaignCategoryModel>.from(json.decode(str).map((x) => CampaignCategoryModel.fromJson(x)));

String campaignCategoryModelToJson(List<CampaignCategoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CampaignCategoryModel {
    String? id;
    String? name;
    String? icon;

    CampaignCategoryModel({
        this.id,
        this.name,
        this.icon,
    });

    factory CampaignCategoryModel.fromJson(Map<String, dynamic> json) => CampaignCategoryModel(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
    };
}
