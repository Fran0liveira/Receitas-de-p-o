import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:receitas_de_pao/notification/time_zone_model.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:timezone/standalone.dart';

class NotificationService {
  static int _id = 1;
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  static Future<void> initialize() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    int id,
    String title,
    String body,
    bool multiline = false,
    DateTime scheduledTime,
    bool onGoing = false,
    bool playSound = false,
    bool enableVibration = false,
  }) async {
    DateTime notificationDt = scheduledTime ?? _getNowDateTime();
    TZDateTime zonedTime = await TimeZoneModel().fromDateTime(notificationDt);
    TZDateTime now = await TimeZoneModel().fromDateTime(DateTime.now());

    if (zonedTime.isBefore(now)) {
      log('retornando notificaoes antigas');
      return;
    }

    flutterLocalNotificationsPlugin.zonedSchedule(
      id ?? _id++,
      title,
      multiline ? '' : body,
      zonedTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          color: Palete().PINK_700,
          channelDescription: 'Main channel notifications',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@drawable/ic_notification',
          channelShowBadge: true,
          styleInformation: multiline ? BigTextStyleInformation(body) : null,
          enableVibration: enableVibration,
          playSound: playSound,
          ongoing: onGoing,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  static DateTime _getNowDateTime() {
    return DateTime.now().add(Duration(seconds: 5));
  }
}
