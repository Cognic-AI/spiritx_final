import 'package:latlong2/latlong.dart';

class HealthCenterModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final List<String> services;
  final LatLng position;
  final String? imageUrl;
  final Map<String, dynamic>? operatingHours;

  HealthCenterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.services,
    required this.position,
    this.imageUrl,
    this.operatingHours,
  });

  factory HealthCenterModel.fromJson(Map<String, dynamic> json) {
    return HealthCenterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      services: json['services'] != null 
          ? List<String>.from(json['services']) 
          : [],
      position: LatLng(
        json['position']['latitude'] ?? 0.0,
        json['position']['longitude'] ?? 0.0,
      ),
      imageUrl: json['imageUrl'],
      operatingHours: json['operatingHours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'services': services,
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'imageUrl': imageUrl,
      'operatingHours': operatingHours,
    };
  }
}
