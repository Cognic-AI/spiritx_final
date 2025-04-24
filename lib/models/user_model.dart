class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'sportsperson' or 'student'
  final String? nicNumber;
  final String? profileImageUrl;
  final List<String>? interests;
  final List<String>? favoriteEquipmentSites;
  final bool isVerified;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final int? height;
  final int? weight;
  final String? emergencyContact;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.nicNumber,
    this.profileImageUrl,
    this.interests,
    this.favoriteEquipmentSites,
    this.isVerified = false,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.emergencyContact,
    this.latitude,
    this.longitude,
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
      isVerified: json['isVerified'] ?? false,
      phone: json['phone'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'],
      height: json['height'],
      weight: json['weight'],
      emergencyContact: json['emergencyContact'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
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
      'isVerified': isVerified,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'height': height,
      'weight': weight,
      'emergencyContact': emergencyContact,
      'latitude': latitude,
      'longitude': longitude,
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
    bool? isVerified,
    String? phone,
    String? address,
    String? dateOfBirth,
    int? height,
    int? weight,
    String? emergencyContact,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      nicNumber: nicNumber ?? this.nicNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      favoriteEquipmentSites:
          favoriteEquipmentSites ?? this.favoriteEquipmentSites,
      isVerified: isVerified ?? this.isVerified,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
