import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:greyfundr/services/local_storage.dart';

// Background message handler - MUST be a top-level function
// @pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
  log('Message data: ${message.data}');
  log('Message notification: ${message.notification?.title} - ${message.notification?.body}');

  // Show local notification for background messages
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@drawable/ic_notification',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id: message.hashCode,
    // message.hashCode,
   title: message.notification?.title ?? 'Notification',
   body: message.notification?.body ?? 'You have a new message',
   notificationDetails: platformChannelSpecifics,
  );
} 

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();
final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_notification');

final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsDarwin,
);

class NotificationService {
  final FirebaseMessaging firebase = FirebaseMessaging.instance;

  Future<void> configure() async {
    bool firstTime =
        await localStorage.getBool("firstTimeNotificationRequest") ?? true;
    bool hasPermission = await requestNotificationPermissions();
    if (!hasPermission && !firstTime) {
      log("LOCATION PERMISSION DENIED REQUESTING SETTINGS ACCESS");
     

      return;
    } else {
      log("LOCATION PERMISSION GRANTED");
    }

    log("::::::::: CONFIGURING NOTIFICATIONS :::::::::");

    // Set the background messaging handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin.initialize(
     settings:  initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log('Notification tapped: ${response.payload}');
        // Handle notification tap here
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log(":::::::: FOREGROUND MESSAGE RECEIVED ::::::::\n${message.data}");

      RemoteNotification? notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
         id: notification.hashCode,
         title: notification.title,
         body: notification.body,
         notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: "@drawable/ic_notification",
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Message opened from notification: ${message.messageId}');
      log('Message data: ${message.data}');
      // Handle navigation or other actions when notification is tapped
    });

    // Subscribe to topics when setup is complete
    // subscribeToFCM();
    localStorage.setBool("firstTimeNotificationRequest", false);
  }

  Future<bool> requestNotificationPermissions() async {
    NotificationSettings settings = await firebase.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("::::::::: NOTIFICATION PERMISSION GRANTED :::::::::");
      return true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log("::::::::: NOTIFICATION PROVISIONAL PERMISSION GRANTED :::::::::");
      return true;
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log("::::::::: NOTIFICATION PERMISSION DENIED :::::::::");
      return false; // Stop further execution in `configure()`
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      log("::::::::: NOTIFICATION PERMISSION NOT DETERMINED :::::::::");
      return false; // Stop further execution in `configure()`
    } else {
      log("::::::::: NOTIFICATION PERMISSION STATUS UNKNOWN :::::::::");
      return false; // Stop further execution in `configure()`
    }
  }

  

  void subscribeToTopic(String topic) {
    log("::::::::: SUBSCRIBING TO TOPIC: $topic :::::::::");
    firebase.subscribeToTopic(topic);
  }

  Future unsubscribeFromTopic(String topic) async {
    log("::::::::: UNSUBSCRIBING FROM TOPIC: $topic :::::::::");
    try {
      await firebase.unsubscribeFromTopic(topic);
    } catch (e) {
      
    }
  }

  Future<void> showResumeFundsNotification() async {
    var notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id, // reuse your high_importance_channel
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0, // notification id
      title: 'Test Notification', // title
      body: 'Test notification from x learn', // body text
      notificationDetails: notificationDetails,
      payload: 'resume_funds', // optional payload
    );
  }
}
