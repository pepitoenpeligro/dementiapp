class Link {
  String? linkId;
  String? caretaker;
  String? cared;

  int? createdAt;

  @override
  String toString() {
    return toJson().toString();
  }

  Link.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }

    linkId = map['linkId'];
    caretaker = map['caretaker'];
    cared = map['cared'];
    createdAt = map['createdAt'];
  }

  Map toJson() => {
        'invitlinkIdationId': linkId,
        'caretaker': caretaker,
        'cared': cared,
        'createdAt': createdAt
      };
}
