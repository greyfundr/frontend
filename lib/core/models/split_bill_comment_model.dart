import 'dart:convert';

SplitBillCommentResponse splitBillCommentResponseFromJson(String str) =>
    SplitBillCommentResponse.fromJson(json.decode(str));

class SplitBillCommentResponse {
  final List<SplitBillComment> comments;
  final int? total;
  final int? page;
  final int? totalPages;

  SplitBillCommentResponse({
    this.comments = const [],
    this.total,
    this.page,
    this.totalPages,
  });

  factory SplitBillCommentResponse.fromJson(Map<String, dynamic> json) =>
      SplitBillCommentResponse(
        comments: json["comments"] == null
            ? []
            : List<SplitBillComment>.from(
                (json["comments"] as List).map(
                  (x) => SplitBillComment.fromJson(x),
                ),
              ),
        total: json["total"],
        page: json["page"],
        totalPages: json["totalPages"],
      );
}

class SplitBillComment {
  final String? id;
  final String? content;
  final String? displayName;
  final String? displayType;
  final String? participantId;
  final String? authorId;
  final bool isGuest;
  final bool isPinned;
  final bool isEdited;
  final DateTime? editedAt;
  final String? transactionId;
  final DateTime? createdAt;

  SplitBillComment({
    this.id,
    this.content,
    this.displayName,
    this.displayType,
    this.participantId,
    this.authorId,
    this.isGuest = false,
    this.isPinned = false,
    this.isEdited = false,
    this.editedAt,
    this.transactionId,
    this.createdAt,
  });

  factory SplitBillComment.fromJson(Map<String, dynamic> json) =>
      SplitBillComment(
        id: json["id"]?.toString(),
        content: json["content"],
        displayName: json["displayName"],
        displayType: json["displayType"],
        participantId: json["participantId"]?.toString(),
        authorId: json["authorId"]?.toString(),
        isGuest: json["isGuest"] == true,
        isPinned: json["isPinned"] == true,
        isEdited: json["isEdited"] == true,
        editedAt: json["editedAt"] == null
            ? null
            : DateTime.tryParse(json["editedAt"].toString()),
        transactionId: json["transactionId"]?.toString(),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"].toString()),
      );
}
