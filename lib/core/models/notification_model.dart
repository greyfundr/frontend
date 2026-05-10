// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
    List<Notification>? notifications;
    int? total;
    int? unreadCount;
    int? page;
    int? totalPages;

    NotificationModel({
        this.notifications,
        this.total,
        this.unreadCount,
        this.page,
        this.totalPages,
    });

    factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        notifications: json["notifications"] == null ? [] : List<Notification>.from(json["notifications"]!.map((x) => Notification.fromJson(x))),
        total: json["total"],
        unreadCount: json["unreadCount"],
        page: json["page"],
        totalPages: json["totalPages"],
    );

    Map<String, dynamic> toJson() => {
        "notifications": notifications == null ? [] : List<dynamic>.from(notifications!.map((x) => x.toJson())),
        "total": total,
        "unreadCount": unreadCount,
        "page": page,
        "totalPages": totalPages,
    };
}

class Notification {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    String? title;
    String? message;
    String? type;
    Metadata? metadata;
    bool? isRead;
    dynamic readAt;

    Notification({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.title,
        this.message,
        this.type,
        this.metadata,
        this.isRead,
        this.readAt,
    });

    factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        title: json["title"],
        message: json["message"],
        type: json["type"],
        metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
        isRead: json["isRead"],
        readAt: json["readAt"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "title": title,
        "message": message,
        "type": type,
        "metadata": metadata?.toJson(),
        "isRead": isRead,
        "readAt": readAt,
    };
}

class Metadata {
    String? link;
    String? email;
    String? billId;
    String? pushToken;
    String? phoneNumber;
    String? participantId;
    String? queryMessage;
    bool? fullyPaid;
    String? otp;
    String? category;

    Metadata({
        this.link,
        this.email,
        this.billId,
        this.pushToken,
        this.phoneNumber,
        this.participantId,
        this.queryMessage,
        this.fullyPaid,
        this.otp,
        this.category,
    });

    factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        link: json["link"],
        email: json["email"],
        billId: json["billId"],
        pushToken: json["pushToken"],
        phoneNumber: json["phoneNumber"],
        participantId: json["participantId"],
        queryMessage: json["queryMessage"],
        fullyPaid: json["fullyPaid"],
        otp: json["otp"],
        category: json["category"],
    );

    Map<String, dynamic> toJson() => {
        "link": link,
        "email": email,
        "billId": billId,
        "pushToken": pushToken,
        "phoneNumber": phoneNumber,
        "participantId": participantId,
        "queryMessage": queryMessage,
        "fullyPaid": fullyPaid,
        "otp": otp,
        "category": category,
    };
}
 