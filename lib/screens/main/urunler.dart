class Urun {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  Urun({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      id: json['id'] ?? 0,
      name: json['title'] ?? 'No Name',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: (json['images'] as List<dynamic>?)?.isNotEmpty == true ? (json['images'] as List<dynamic>).first : 'https://via.placeholder.com/150',
      category: json['category'] ?? 'No Category',
    );
  }
}
