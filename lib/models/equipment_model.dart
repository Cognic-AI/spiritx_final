class EquipmentModel {
  final String id;
  final String name;
  final String price;
  final String currency; // Added currency field
  final String store;
  final double rating;
  final String? imageUrl;
  final String? url;
  final List<String>? tags;
  final String? category;
  final bool? availability; // Added availability field
  final String? shipping; // Added shipping field
  final String? deliveryDate; // Added delivery date field
  final String? deliveryCost; // Added delivery cost field
  final String? warranty; // Added warranty field
  final String? description; // Added description field

  EquipmentModel({
    required this.id,
    required this.name,
    required this.price,
    required this.currency, // Updated constructor
    required this.store,
    required this.rating,
    this.imageUrl,
    this.url,
    this.tags,
    this.category,
    this.availability, // Updated constructor
    this.shipping, // Updated constructor
    this.deliveryDate, // Updated constructor
    this.deliveryCost, // Updated constructor
    this.warranty, // Updated constructor
    this.description, // Updated constructor
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] ?? '',
      name: json['product_name'] ?? '', // Updated to match new JSON structure
      price: json['price'] ?? '',
      currency: json['currency'] ?? '', // Updated to match new JSON structure
      store: json['store'] ?? '',
      rating: (json['product_rating'] ?? 0.0).toDouble(), // Updated to match new JSON structure
      imageUrl: json['imageUrl'],
      url: json['product_url'], // Updated to match new JSON structure
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      category: json['category'],
      availability: json['availability'], // Updated to match new JSON structure
      shipping: json['shipping'], // Updated to match new JSON structure
      deliveryDate: json['delivery_date'], // Updated to match new JSON structure
      deliveryCost: json['delivery_cost'], // Updated to match new JSON structure
      warranty: json['warranty'], // Updated to match new JSON structure
      description: json['description'], // Updated to match new JSON structure
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency, // Updated to include currency
      'store': store,
      'rating': rating,
      'imageUrl': imageUrl,
      'url': url,
      'tags': tags,
      'category': category,
      'availability': availability, // Updated to include availability
      'shipping': shipping, // Updated to include shipping
      'delivery_date': deliveryDate, // Updated to include delivery date
      'delivery_cost': deliveryCost, // Updated to include delivery cost
      'warranty': warranty, // Updated to include warranty
      'description': description, // Updated to include description
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
