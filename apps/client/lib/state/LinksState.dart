import 'package:location/models/User.dart';
import 'package:location/state/AppState.dart';

class LinksState extends AppState {
  final List<User> linksUserCollection = [];

  void addItem(User user) {
    linksUserCollection.add(user);
    notifyListeners();
  }
}
