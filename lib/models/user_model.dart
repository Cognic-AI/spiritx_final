class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'sportsperson' or 'student'
  final String? nicNumber;
  final String? profileImageUrl;
  final List<String>? interests;
  final List<String>? favoriteEquipmentSites;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.nicNumber,
    this.profileImageUrl,
    this.interests,
    this.favoriteEquipmentSites,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'student',
      nicNumber: json['nicNumber'],
      profileImageUrl: json['profileImageUrl'],
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : null,
      favoriteEquipmentSites: json['favoriteEquipmentSites'] != null 
          ? List<String>.from(json['favoriteEquipmentSites']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'nicNumber': nicNumber,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
      'favoriteEquipmentSites': favoriteEquipmentSites,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? nicNumber,
    String? profileImageUrl,
    List<String>? interests,
    List<String>? favoriteEquipmentSites,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      nicNumber: nicNumber ?? this.nicNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      favoriteEquipmentSites: favoriteEquipmentSites ?? this.favoriteEquipmentSites,
    );
  }
}
