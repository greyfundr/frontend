// To parse this JSON data, do
//
//     final campaignComment = campaignCommentFromJson(jsonString);

import 'dart:convert';

CampaignComment campaignCommentFromJson(String str) =>
    CampaignComment.fromJson(json.decode(str));

String campaignCommentToJson(CampaignComment data) =>
    json.encode(data.toJson());

List<CampaignComment> campaignCommentsFromJson(String str) =>
    List<CampaignComment>.from(
      (json.decode(str) as List).map((x) => CampaignComment.fromJson(x)),
    );

class CampaignComment {
  String? id;
  String? campaignId;
  String? userId;
  String? content;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isEdited;
  String? firstName;
  String? lastName;
  String? username;
  String? profileImage;

  CampaignComment({
    this.id,
    this.campaignId,
    this.userId,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.isEdited,
    this.firstName,
    this.lastName,
    this.username,
    this.profileImage,
  });

  String get displayName {
    final full = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    if (full.isNotEmpty) return full;
    if ((username ?? '').isNotEmpty) return username!;
    return 'Anonymous';
  }

  factory CampaignComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;
    return CampaignComment(
      id: json['id']?.toString(),
      campaignId: json['campaignId']?.toString(),
      userId: json['userId']?.toString(),
      content: json['content']?.toString(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'].toString()),
      isEdited: json['isEdited'] as bool?,
      firstName: (json['firstName'] ?? user?['firstName'])?.toString(),
      lastName: (json['lastName'] ?? user?['lastName'])?.toString(),
      username: (json['username'] ?? user?['username'])?.toString(),
      profileImage:
          (json['profileImage'] ?? user?['profileImage'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'campaignId': campaignId,
        'userId': userId,
        'content': content,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isEdited': isEdited,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'profileImage': profileImage,
      };
}
