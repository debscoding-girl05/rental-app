import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:landlord_os/core/utils/logger.dart';
import 'package:landlord_os/features/tenants/domain/tenant_model.dart';

/// Handles local notifications for rent due-date reminders.
class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification plugin and timezone data.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
    AppLogger.info('NotificationService initialized');
  }

  /// Request notification permissions (iOS).
  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  /// Compute the next due date for a tenant based on lease start and frequency.
  DateTime? _nextDueDate(Tenant tenant) {
    final start = tenant.leaseStart;
    if (start == null) return null;

    final now = DateTime.now();
    final monthInterval = switch (tenant.paymentFrequency) {
      'quarterly' => 3,
      'biannual' => 6,
      'annual' => 12,
      _ => 1, // monthly
    };

    // Walk forward from lease start by frequency intervals until we pass now.
    var due = DateTime(start.year, start.month, start.day);
    while (due.isBefore(now) || due.isAtSameMomentAs(now)) {
      due = DateTime(due.year, due.month + monthInterval, due.day);
    }

    // If tenant has a lease end and due is past it, no more reminders.
    if (tenant.leaseEnd != null && due.isAfter(tenant.leaseEnd!)) {
      return null;
    }

    return due;
  }

  /// Unique notification ID from tenant ID hash. Two IDs per tenant:
  /// - base ID for the "3 days before" reminder
  /// - base ID + 1 for the "due today" reminder
  int _baseId(String tenantId) => tenantId.hashCode.abs() % 100000;

  /// Schedule rent reminders for a single tenant.
  Future<void> scheduleRentReminder(Tenant tenant) async {
    if (!_initialized) return;

    // Cancel existing reminders first.
    await cancelTenantReminders(tenant.id);

    final dueDate = _nextDueDate(tenant);
    if (dueDate == null) return;

    final baseId = _baseId(tenant.id);
    final amount = tenant.rentAmount.toStringAsFixed(0);
    final name = tenant.fullName;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rent_reminders',
        'Rent Reminders',
        channelDescription: 'Notifications for upcoming rent due dates',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // 3 days before
    final reminderDate = dueDate.subtract(const Duration(days: 3));
    if (reminderDate.isAfter(DateTime.now())) {
      final tzReminder = tz.TZDateTime.from(reminderDate, tz.local);
      await _plugin.zonedSchedule(
        baseId,
        'Rent Reminder',
        '$name\'s rent ($amount FCFA) is due in 3 days',
        tzReminder,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      AppLogger.info(
        'Scheduled 3-day reminder for $name on $reminderDate',
      );
    }

    // Due date
    final tzDue = tz.TZDateTime.from(dueDate, tz.local);
    if (dueDate.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId + 1,
        'Rent Due Today',
        '$name owes $amount FCFA — rent is due today',
        tzDue,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      AppLogger.info('Scheduled due-date reminder for $name on $dueDate');
    }
  }

  /// Cancel all reminders for a tenant.
  Future<void> cancelTenantReminders(String tenantId) async {
    if (!_initialized) return;
    final baseId = _baseId(tenantId);
    await _plugin.cancel(baseId);
    await _plugin.cancel(baseId + 1);
  }

  /// Reschedule reminders for all active tenants.
  Future<void> rescheduleAllReminders(List<Tenant> tenants) async {
    if (!_initialized) return;
    await _plugin.cancelAll();
    for (final tenant in tenants) {
      await scheduleRentReminder(tenant);
    }
    AppLogger.info(
      'Rescheduled reminders for ${tenants.length} tenant(s)',
    );
  }
}
