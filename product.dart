class Product {
  final String id;
  final String name;
  final String description;
  final int pointsRequired;
  final double priceInMoney; // New field for wallet money purchase
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final int stock;
  final List<String> features;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.priceInMoney,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
    required this.stock,
    required this.features,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    pointsRequired: json['pointsRequired'],
    priceInMoney: (json['priceInMoney'] ?? 0.0).toDouble(),
    category: json['category'],
    imageUrl: json['imageUrl'],
    isAvailable: json['isAvailable'],
    stock: json['stock'],
    features: List<String>.from(json['features']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'pointsRequired': pointsRequired,
    'priceInMoney': priceInMoney,
    'category': category,
    'imageUrl': imageUrl,
    'isAvailable': isAvailable,
    'stock': stock,
    'features': features,
  };
}