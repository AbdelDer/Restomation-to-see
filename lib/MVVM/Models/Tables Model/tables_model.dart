class TablesModel {
  TablesModel({
    required this.id,
    required this.name,
    required this.qrLink,
    required this.restaurantId,
  });
  String? id;
  final String? name;
  final String? restaurantId;
  final String? qrLink;

  factory TablesModel.fromFirestore(Map doc) {
    return TablesModel(
        id: doc["id"] ?? "No id provided",
        name: doc["name"] ?? "No name provided",
        qrLink: doc["qrLink"] ?? "No path provided",
        restaurantId: doc["restaurant_id"] ?? "No restaurant ID provided");
  }
}
