import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _plugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Initialize notification service
  Future<void> init() async {
    _plugin = FlutterLocalNotificationsPlugin();

    // Initialize timezone & Set Lokal ke WITA (Palu)
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Makassar')); 

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  // Request notification permissions (Update untuk Android 13+ dan iOS)
  Future<bool> requestPermissions() async {
    // 1. Request untuk Android 13+ (PENTING BUAT HP BARU)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 2. Request untuk iOS
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
        
    return result ?? true; // Default true untuk Android di bawah 13
  }

  // Schedule notification untuk task (X hari sebelum deadline)
  Future<void> scheduleTaskNotification(
    Task task, {
    int daysBeforeDeadline = 1,
  }) async {
    try {
      // Parse deadline (format: DD/MM/YYYY)
      final parts = task.deadline.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Create DateTime untuk deadline (Set Alarm jam 08:00 Pagi)
      final deadlineDate = DateTime(year, month, day, 8, 0);

      // Subtract days untuk notification time
      final notificationTime = deadlineDate.subtract(
        Duration(days: daysBeforeDeadline),
      );

      // Jangan schedule kalau waktu sudah lewat
      if (notificationTime.isBefore(DateTime.now())) {
        print('Notification time sudah lewat untuk task: ${task.title}');
        return;
      }

      // Convert ke timezone lokal (WITA)
      final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

      final androidDetails = const AndroidNotificationDetails(
        'task_deadline_channel',
        'Task Deadline Reminders',
        channelDescription:
            'Notifikasi reminder untuk task yang akan segera deadline',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      final iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification
      await _plugin.zonedSchedule(
        task.id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000), // Antisipasi jika id null
        'Tugas: ${task.title}',
        'Deadline dalam $daysBeforeDeadline hari - ${task.deadline}',
        tzNotificationTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // <--- Update versi baru
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('Notifikasi scheduled untuk: ${task.title} pada $tzNotificationTime');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Schedule multiple notifications untuk 1 task (berbagai hari sebelum deadline)
  Future<void> scheduleTaskNotifications(
    Task task, {
    List<int> daysBeforeDeadline = const [1, 3, 7],
  }) async {
    for (int days in daysBeforeDeadline) {
      await scheduleTaskNotification(task, daysBeforeDeadline: days);
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int taskId) async {
    await _plugin.cancel(taskId);
    print('Notifikasi cancelled untuk task ID: $taskId');
  }

  // Cancel semua notification
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    print('Semua notifikasi di-cancel');
  }

  // Show instant notification (Sangat berguna buat testing)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_notification_channel',
      'Instant Notifications',
      channelDescription: 'Notifikasi instan untuk testing',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().microsecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Get pending notifications count
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}