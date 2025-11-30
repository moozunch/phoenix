
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
    Future<void> showNotification({
      required int id,
      required String title,
      required String body,
    }) async {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'daily_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    }
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // icon
      [
        NotificationChannel(
          channelKey: 'daily_channel',
          channelName: 'Daily Notifications',
          channelDescription: 'Daily reminders',
          defaultColor: const Color(0xFFDF2A00),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: 'weekly_channel',
          channelName: 'Weekly Notifications',
          channelDescription: 'Weekly reminders',
          defaultColor: const Color(0xFFDF2A00),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );
    await requestPermission();
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'daily_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday, // 1=Monday, 7=Sunday
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'weekly_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        weekday: weekday,
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }
}
