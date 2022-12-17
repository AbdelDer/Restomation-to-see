class MenuModel {
  MenuModel({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.reviews,
    required this.status,
    required this.type,
    required this.upselling,
  });

  final String? name;
  final String? description;
  final String? imagePath;
  final String? price;
  final String? reviews;
  final String? type;
  final String? status;
  final String? upselling;

  factory MenuModel.fromFirestore(Map item) {
    return MenuModel(
        name: item["name"] ?? "No name provided",
        description: item["description"] ?? "No description provided",
        imagePath: item["imagePath"] ?? "No imagePath provided",
        price: item["price"] ?? "No price provided",
        reviews: item["reviews"] ?? "No reviews provided",
        type: item["type"] ?? "No type provided",
        status: item["status"] ?? "unavailable",
        upselling: item["upselling"] ?? "No upselling provided");
  }
}
