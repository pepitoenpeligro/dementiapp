class Invitation {
  String? invitationId;
  String? caretaker;
  String? cared;

  int? createdAt;

  @override
  String toString() {
    return toJson().toString();
  }

  Invitation.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }

    invitationId = map['invitationId'];
    caretaker = map['caretaker'];
    cared = map['cared'];
    createdAt = map['createdAt'];
  }

  Map toJson() => {
        'invitationId': invitationId,
        'caretaker': caretaker,
        'cared': cared,
        'createdAt': createdAt
      };
}
