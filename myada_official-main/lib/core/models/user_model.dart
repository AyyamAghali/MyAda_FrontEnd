class UserModel {
  final int id;
  final int groupId;
  final int? cardsId;
  final String name;
  final String email;
  final bool hasException;
  final String createdAt;
  final String updatedAt;
  final PersonalInformationModel personalInformation;
  final String uid;

  UserModel({
    required this.id,
    required this.groupId,
    this.cardsId,
    required this.name,
    required this.email,
    required this.hasException,
    required this.createdAt,
    required this.updatedAt,
    required this.personalInformation,
    required this.uid,
  });

  UserRole get role {
    // Updated mapping based on backend configuration
    switch (groupId) {
      case 1:
        return UserRole.teacher; // group_id 1 = teacher
      case 2:
        return UserRole.student; // group_id 2 = student
      case 3:
        return UserRole.staff; // group_id 3 = staff
      default:
        return UserRole.student; // Default fallback
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      groupId: json['group_id'],
      cardsId: json['cards_id'],
      name: json['name'],
      email: json['email'],
      hasException: json['hasException'] == 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      personalInformation:
          PersonalInformationModel.fromJson(json['personal_informations']),
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'cards_id': cardsId,
      'name': name,
      'email': email,
      'hasException': hasException ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'personal_informations': personalInformation.toJson(),
      'uid': uid,
    };
  }
}

class PersonalInformationModel {
  final int id;
  final int userId;
  final String uid;
  final String fullName;
  final String username;
  final String birthdate;
  final String createdAt;
  final String updatedAt;
  final int myRoomId;

  PersonalInformationModel({
    required this.id,
    required this.userId,
    required this.uid,
    required this.fullName,
    required this.username,
    required this.birthdate,
    required this.createdAt,
    required this.updatedAt,
    required this.myRoomId,
  });

  factory PersonalInformationModel.fromJson(Map<String, dynamic> json) {
    return PersonalInformationModel(
      id: json['id'],
      userId: json['user_id'],
      uid: json['uid'],
      fullName: json['fullName'],
      username: json['username'],
      birthdate: json['birthdate'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      myRoomId: json['myRoomID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'birthdate': birthdate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'myRoomID': myRoomId,
    };
  }
}

enum UserRole {
  student,
  teacher,
  staff,
}
