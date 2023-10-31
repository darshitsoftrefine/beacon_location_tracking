import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotifyService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {}
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async{}
    );
  }

  Future showNotification(
      {required int id, String? title, String? body, String? payload }) async {
    return notificationsPlugin.show(id, title, body, await notificationDetails());
  }
  Future cancelNotification({required int id}) async {
    return notificationsPlugin.cancel(id);
  }
}



  notificationDetails() {
   return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max),
      iOS: DarwinNotificationDetails()
  );


}