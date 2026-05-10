import 'package:flutter/material.dart';
import '../data/services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _notificationsEnabled = true;
  int _daysBefore = 1; // Default: 1 hari sebelum deadline
  List<int> _multipleDays = [1, 3, 7]; // Multiple reminders: 1, 3, 7 hari

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  int get daysBefore => _daysBefore;
  List<int> get multipleDays => _multipleDays;

  // Initialize notification service
  Future<void> initNotificationService() async {
    try {
      await _notificationService.init();
      await _notificationService.requestPermissions();
      print('Notification service initialized');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  // Toggle notifications on/off
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    if (!enabled) {
      _notificationService.cancelAllNotifications();
    }
    notifyListeners();
  }

  // Set days before deadline untuk reminder
  void setDaysBeforeDeadline(int days) {
    _daysBefore = days;
    notifyListeners();
  }

  // Set multiple reminder days
  void setMultipleDays(List<int> days) {
    _multipleDays = days;
    notifyListeners();
  }

  // Schedule task notification
  Future<void> scheduleTaskNotification(dynamic task) async {
    if (!_notificationsEnabled) return;

    try {
      await _notificationService.scheduleTaskNotifications(
        task,
        daysBeforeDeadline: _multipleDays,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Cancel task notification
  Future<void> cancelTaskNotification(int taskId) async {
    try {
      await _notificationService.cancelNotification(taskId);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  // Show test notification
  Future<void> showTestNotification() async {
    await _notificationService.showInstantNotification(
      title: 'Test Notification',
      body: 'Notifikasi berhasil dikirim! 🎉',
      payload: 'test',
    );
  }

  // Get pending notifications
  Future<int> getPendingNotificationsCount() async {
    final pending = await _notificationService.getPendingNotifications();
    return pending.length;
  }
}
