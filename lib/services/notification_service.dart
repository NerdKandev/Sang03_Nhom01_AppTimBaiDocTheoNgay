import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../services/data_service.dart';
import '../screens/sutra_reading_screen.dart';
import '../utils/navigation_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    // Set default timezone (Asia/Ho_Chi_Minh for Vietnam)
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (e) {
      print('Error setting timezone: $e');
      // Fallback to UTC if timezone is not available
    }

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // Request permissions for iOS
    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _isInitialized = true;
    print('NotificationService initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) async {
    print('Notification tapped: ${response.payload}');
    
    if (response.payload == null || response.payload!.isEmpty) {
      print('No payload in notification');
      return;
    }

    final reminderId = response.payload!;
    
    try {
      // Get reminder from ReminderService
      final reminderService = ReminderService();
      final reminders = reminderService.allReminders;
      final reminder = reminders.firstWhere(
        (r) => r.id == reminderId,
      );

      // Get the first sutra from the reminder
      if (reminder.sutraIds.isEmpty) {
        print('No sutras in reminder');
        return;
      }

      final dataService = DataService();
      final firstSutraId = reminder.sutraIds.first;
      final sutra = dataService.sutras.firstWhere(
        (s) => s.id == firstSutraId,
      );

      // Navigate to SutraReadingScreen
      final navigator = NavigationService.navigatorKey.currentState;
      if (navigator != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => SutraReadingScreen(sutra: sutra),
          ),
        );
      } else {
        print('Navigator not available');
      }
    } catch (e) {
      print('Error handling notification tap: $e');
      // If reminder or sutra not found, just ignore the tap
    }
  }

  /// Schedule a notification for a reminder
  /// Returns the notification IDs created (for both 30-min advance and main notification)
  Future<List<int>> scheduleReminderNotifications(ReminderModel reminder) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Calculate the scheduled DateTime
    final scheduledDateTime = DateTime(
      reminder.date.year,
      reminder.date.month,
      reminder.date.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    // Only schedule if the time is in the future
    if (scheduledDateTime.isBefore(DateTime.now())) {
      print('Reminder time is in the past, not scheduling: $scheduledDateTime');
      return [];
    }

    final notificationIds = <int>[];
    // Use hash code of reminder ID to ensure uniqueness and avoid overflow
    final reminderId = reminder.id.hashCode.abs();

    // Notification content
    final sutraTitlesText = reminder.sutraTitles.length > 3
        ? '${reminder.sutraTitles.take(3).join(", ")} và ${reminder.sutraTitles.length - 3} bài khác'
        : reminder.sutraTitles.join(", ");
    
    final title = 'Nhắc lịch đọc kinh';
    final body = 'Danh mục: ${reminder.categoryName}\nBài đọc: $sutraTitlesText';

    // 1. Schedule notification 30 minutes before
    final advanceDateTime = scheduledDateTime.subtract(const Duration(minutes: 30));
    if (advanceDateTime.isAfter(DateTime.now())) {
      final advanceNotificationId = reminderId; // Use reminder ID for advance notification
      await _scheduleNotification(
        id: advanceNotificationId,
        scheduledDate: advanceDateTime,
        title: '$title (Nhắc trước 30 phút)',
        body: body,
        payload: reminder.id,
      );
      notificationIds.add(advanceNotificationId);
      print('Scheduled advance notification at: $advanceDateTime');
    }

    // 2. Schedule main notification at the exact time
    final mainNotificationId = reminderId + 1000000; // Offset to avoid collision
    await _scheduleNotification(
      id: mainNotificationId,
      scheduledDate: scheduledDateTime,
      title: title,
      body: body,
      payload: reminder.id,
    );
    notificationIds.add(mainNotificationId);
    print('Scheduled main notification at: $scheduledDateTime');

    return notificationIds;
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Convert to TZDateTime
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Android notification details
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Nhắc lịch đọc kinh',
        channelDescription: 'Thông báo nhắc lịch đọc kinh',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Cancel notifications for a reminder
  Future<void> cancelReminderNotifications(ReminderModel reminder) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Use hash code of reminder ID to ensure uniqueness
    final reminderId = reminder.id.hashCode.abs();
    final advanceNotificationId = reminderId;
    final mainNotificationId = reminderId + 1000000;

    await _notifications.cancel(advanceNotificationId);
    await _notifications.cancel(mainNotificationId);
    
    print('Cancelled notifications for reminder: ${reminder.id}');
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    await _notifications.cancelAll();
    print('Cancelled all notifications');
  }

  /// Reschedule all active reminders
  Future<void> rescheduleAllReminders(List<ReminderModel> reminders) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel all existing notifications first
    await cancelAllNotifications();

    // Schedule notifications for all active reminders
    for (final reminder in reminders) {
      if (reminder.isActive) {
        await scheduleReminderNotifications(reminder);
      }
    }

    print('Rescheduled notifications for ${reminders.length} reminders');
  }
}

