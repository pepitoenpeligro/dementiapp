import 'package:equatable/equatable.dart';

class User extends Equatable {
  String? email;
  String? userId;
  String? displayName;
  String? userName;
  String? profilePic;
  bool? firstLogin;
  String? location;
  int? createdAt;
  bool? isVerified;
  String? notificationToken;
  String? authorizationToken;
  String? participation;
  int? birthdate;

  User(
      {this.email,
      this.userId,
      this.displayName,
      this.userName,
      this.profilePic,
      this.firstLogin,
      this.location,
      this.createdAt,
      this.isVerified,
      this.notificationToken,
      this.authorizationToken,
      this.participation,
      this.birthdate});

  void setUserId(String nuserId) {
    userId = nuserId;
  }

  toJson() {
    return {
      "userId": userId,
      "email": email,
      'displayName': displayName,
      'profilePic': profilePic,
      'firstLogin': firstLogin,
      'location': location,
      'createdAt': createdAt,
      'userName': userName,
      'isVerified': isVerified ?? false,
      'notificationToken': notificationToken,
      'authorizationToken': authorizationToken,
      'participation': participation,
      'birthdate': birthdate,
    };
  }

  User.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }

    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    profilePic = map['profilePic'];
    firstLogin = map['firstLogin'];
    location = map['location'];
    createdAt = map['createdAt'];
    userName = map['userName'];
    notificationToken = map['notificationToken'];
    authorizationToken = map['authorizationToken'];
    isVerified = map['isVerified'] ?? false;
    participation = map['participation'];
    birthdate = map['birthdate'];
  }

  @override
  List<Object?> get props => [
        email,
        userId,
        displayName,
        userName,
        profilePic,
        firstLogin,
        location,
        createdAt,
        isVerified,
        notificationToken,
        authorizationToken,
        participation,
        birthdate,
      ];
}
