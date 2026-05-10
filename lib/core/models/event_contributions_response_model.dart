// To parse this JSON data, do
//
//     final eventContributions = eventContributionsFromJson(jsonString);

import 'dart:convert';

List<EventContribution> eventContributionsFromJson(String str) =>
    List<EventContribution>.from(
      (json.decode(str) as List).map((x) => EventContribution.fromJson(x)),
    );

String eventContributionsToJson(List<EventContribution> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventContribution {
    String? id;
    DateTime? createdAt;
    dynamic? amount;
    int? isAnonymous;
    String? displayName;
    String? comment;
    String? image;
    User? user;

    EventContribution({
        this.id,
        this.createdAt,
        this.amount,
        this.isAnonymous,
        this.displayName,
        this.comment,
        this.image,
        this.user,
    });

    factory EventContribution.fromJson(Map<String, dynamic> json) => EventContribution(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        amount: json["amount"],
        isAnonymous: json["isAnonymous"],
        displayName: json["displayName"],
        comment: json["comment"],
        image: json["image"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "amount": amount,
        "isAnonymous": isAnonymous,
        "displayName": displayName,
        "comment": comment,
        "image": image,
        "user": user?.toJson(),
    };
}

class User {
    String? firstName;
    String? lastName;
    String? username;
    bool? isPinSet;

    User({
        this.firstName,
        this.lastName,
        this.username,
        this.isPinSet,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        firstName: json["firstName"],
        lastName: json["lastName"],
        username: json["username"],
        isPinSet: json["isPinSet"],
    );

    Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
        "isPinSet": isPinSet,
    };
}