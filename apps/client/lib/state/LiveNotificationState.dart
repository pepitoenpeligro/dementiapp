import 'package:location/models/Notification.dart';
import 'package:location/models/User.dart';
import 'package:location/state/AppState.dart';

class LiveNotificationState extends AppState {
  late List<NotificationModel> liveNotificationCollection = [
    // NotificationModel(title: "uno"),
    // NotificationModel(title: "dos")
  ];

  void addItem(NotificationModel notification) {
    liveNotificationCollection.add(notification);
    notifyListeners();
  }
}
