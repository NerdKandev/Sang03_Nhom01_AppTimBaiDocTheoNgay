import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/reminder_model.dart';
import 'notification_service.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final NotificationService _notificationService = NotificationService();
  List<ReminderModel> _reminders = [];

  List<ReminderModel> get reminders => _reminders.where((r) => r.isActive).toList();
  List<ReminderModel> get allReminders => _reminders;

  Future<void> initializeReminders() async {
    await _notificationService.initialize();
    await _loadReminders();
    // Reschedule all active reminders on app start
    await _notificationService.rescheduleAllReminders(_reminders);
  }

  Future<void> _loadReminders() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reminders.json');

      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<dynamic> remindersData = data['reminders'] ?? [];
        _reminders = remindersData.map((reminder) => ReminderModel.fromMap(reminder)).toList();
        print('Loaded ${_reminders.length} reminders from: ${file.path}');
      } else {
        _reminders = [];
        await _saveReminders();
        print('Created new reminders file');
      }
    } catch (e) {
      print('Error loading reminders: $e');
      _reminders = [];
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    
    // Schedule notifications for the new reminder
    if (reminder.isActive) {
      await _notificationService.scheduleReminderNotifications(reminder);
    }
    
    print('Reminder added: ${reminder.id}');
  }

  Future<void> deleteReminder(String reminderId) async {
    final reminder = _reminders.firstWhere(
      (r) => r.id == reminderId,
      orElse: () => throw Exception('Reminder not found'),
    );
    
    // Cancel notifications before deleting
    await _notificationService.cancelReminderNotifications(reminder);
    
    _reminders.removeWhere((reminder) => reminder.id == reminderId);
    await _saveReminders();
    print('Reminder deleted: $reminderId');
  }

  Future<void> toggleReminderActive(String reminderId) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      final reminder = _reminders[index];
      final newActiveState = !reminder.isActive;
      
      if (newActiveState) {
        // Schedule notifications when activating
        await _notificationService.scheduleReminderNotifications(
          reminder.copyWith(isActive: true),
        );
      } else {
        // Cancel notifications when deactivating
        await _notificationService.cancelReminderNotifications(reminder);
      }
      
      _reminders[index] = reminder.copyWith(isActive: newActiveState);
      await _saveReminders();
      print('Reminder toggled: $reminderId (active: $newActiveState)');
    }
  }

  Future<void> _saveReminders() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reminders.json');

      final Map<String, dynamic> data = {
        'reminders': _reminders.map((reminder) => reminder.toMap()).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(json.encode(data));
      print('Reminders saved successfully to: ${file.path}');
    } catch (e) {
      print('Error saving reminders: $e');
    }
  }

  List<ReminderModel> getRemindersByDate(DateTime date) {
    return _reminders.where((reminder) {
      return reminder.isActive &&
          reminder.date.year == date.year &&
          reminder.date.month == date.month &&
          reminder.date.day == date.day;
    }).toList();
  }
}

