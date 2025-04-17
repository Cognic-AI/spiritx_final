class EquipmentModel {
  final String id;
  final String name;
  final String price;
  final String store;
  final double rating;
  final String? imageUrl;
  final String? url;
  final List<String>? tags;
  final String? category;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.price,
    required this.store,
    required this.rating,
    this.imageUrl,
    this.url,
    this.tags,
    this.category,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      store: json['store'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'],
      url: json['url'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'store': store,
      'rating': rating,
      'imageUrl': imageUrl,
      'url': url,
      'tags': tags,
      'category': category,
    };
  }
}

class EquipmentSearchQuery {
  final String? searchTerm;
  final List<String>? tags;
  final List<String>? stores;
  final String? userId;

  EquipmentSearchQuery({
    this.searchTerm,
    this.tags,
    this.stores,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'searchTerm': searchTerm,
      'tags': tags,
      'stores': stores,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
