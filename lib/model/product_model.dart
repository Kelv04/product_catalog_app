class Product {
  final int id;
  final String title;
  final String description;
  final num price;
  final num rating;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.images,
  });
}