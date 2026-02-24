// To parse this JSON data, do
//
//     final userSettingsModel = userSettingsModelFromJson(jsonString);

import 'dart:convert';

UserSettingsModel userSettingsModelFromJson(String str) => UserSettingsModel.fromJson(json.decode(str));

String userSettingsModelToJson(UserSettingsModel data) => json.encode(data.toJson());

class UserSettingsModel {
    String? id;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;
    NotificationPrefs? notificationPrefs;
    PrivacyControls? privacyControls;
    String? language;
    String? currency;
    bool? twoFactorEnabled;
    dynamic twoFactorSecret;
    bool? emailVerified;
    bool? phoneVerified;

    UserSettingsModel({
        this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.notificationPrefs,
        this.privacyControls,
        this.language,
        this.currency,
        this.twoFactorEnabled,
        this.twoFactorSecret,
        this.emailVerified,
        this.phoneVerified,
    });

    factory UserSettingsModel.fromJson(Map<String, dynamic> json) => UserSettingsModel(
        id: json["id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        notificationPrefs: json["notificationPrefs"] == null ? null : NotificationPrefs.fromJson(json["notificationPrefs"]),
        privacyControls: json["privacyControls"] == null ? null : PrivacyControls.fromJson(json["privacyControls"]),
        language: json["language"],
        currency: json["currency"],
        twoFactorEnabled: json["twoFactorEnabled"],
        twoFactorSecret: json["twoFactorSecret"],
        emailVerified: json["emailVerified"],
        phoneVerified: json["phoneVerified"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "notificationPrefs": notificationPrefs?.toJson(),
        "privacyControls": privacyControls?.toJson(),
        "language": language,
        "currency": currency,
        "twoFactorEnabled": twoFactorEnabled,
        "twoFactorSecret": twoFactorSecret,
        "emailVerified": emailVerified,
        "phoneVerified": phoneVerified,
    };
}

class NotificationPrefs {
    BillReminders? billReminders;
    BillReminders? securityAlerts;
    BillReminders? campaignUpdates;
    BillReminders? socialInteractions;
    BillReminders? paymentConfirmations;
    BillReminders? trustAndAchievements;

    NotificationPrefs({
        this.billReminders,
        this.securityAlerts,
        this.campaignUpdates,
        this.socialInteractions,
        this.paymentConfirmations,
        this.trustAndAchievements,
    });

    factory NotificationPrefs.fromJson(Map<String, dynamic> json) => NotificationPrefs(
        billReminders: json["billReminders"] == null ? null : BillReminders.fromJson(json["billReminders"]),
        securityAlerts: json["securityAlerts"] == null ? null : BillReminders.fromJson(json["securityAlerts"]),
        campaignUpdates: json["campaignUpdates"] == null ? null : BillReminders.fromJson(json["campaignUpdates"]),
        socialInteractions: json["socialInteractions"] == null ? null : BillReminders.fromJson(json["socialInteractions"]),
        paymentConfirmations: json["paymentConfirmations"] == null ? null : BillReminders.fromJson(json["paymentConfirmations"]),
        trustAndAchievements: json["trustAndAchievements"] == null ? null : BillReminders.fromJson(json["trustAndAchievements"]),
    );

    Map<String, dynamic> toJson() => {
        "billReminders": billReminders?.toJson(),
        "securityAlerts": securityAlerts?.toJson(),
        "campaignUpdates": campaignUpdates?.toJson(),
        "socialInteractions": socialInteractions?.toJson(),
        "paymentConfirmations": paymentConfirmations?.toJson(),
        "trustAndAchievements": trustAndAchievements?.toJson(),
    };
}

class BillReminders {
    bool? sms;
    bool? push;
    bool? email;
    bool? inApp;
    String? frequency;

    BillReminders({
        this.sms,
        this.push,
        this.email,
        this.inApp,
        this.frequency,
    });

    factory BillReminders.fromJson(Map<String, dynamic> json) => BillReminders(
        sms: json["sms"],
        push: json["push"],
        email: json["email"],
        inApp: json["inApp"],
        frequency: json["frequency"],
    );

    Map<String, dynamic> toJson() => {
        "sms": sms,
        "push": push,
        "email": email,
        "inApp": inApp,
        "frequency": frequency,
    };
}

class PrivacyControls {
    bool? showBadges;
    bool? showTrustScore;
    String? profileVisibility;
    bool? showCampaignCount;
    bool? dataSharingConsent;
    bool? showActiveCampaigns;
    bool? showContributionCount;
    String? defaultCampaignVisibility;

    PrivacyControls({
        this.showBadges,
        this.showTrustScore,
        this.profileVisibility,
        this.showCampaignCount,
        this.dataSharingConsent,
        this.showActiveCampaigns,
        this.showContributionCount,
        this.defaultCampaignVisibility,
    });

    factory PrivacyControls.fromJson(Map<String, dynamic> json) => PrivacyControls(
        showBadges: json["showBadges"],
        showTrustScore: json["showTrustScore"],
        profileVisibility: json["profileVisibility"],
        showCampaignCount: json["showCampaignCount"],
        dataSharingConsent: json["dataSharingConsent"],
        showActiveCampaigns: json["showActiveCampaigns"],
        showContributionCount: json["showContributionCount"],
        defaultCampaignVisibility: json["defaultCampaignVisibility"],
    );

    Map<String, dynamic> toJson() => {
        "showBadges": showBadges,
        "showTrustScore": showTrustScore,
        "profileVisibility": profileVisibility,
        "showCampaignCount": showCampaignCount,
        "dataSharingConsent": dataSharingConsent,
        "showActiveCampaigns": showActiveCampaigns,
        "showContributionCount": showContributionCount,
        "defaultCampaignVisibility": defaultCampaignVisibility,
    };
}
