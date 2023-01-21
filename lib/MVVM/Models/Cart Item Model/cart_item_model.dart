class CartItemModel {
  CartItemModel({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.reviews,
    required this.status,
    required this.type,
    required this.upselling,
    required this.quantity,
    required this.cookingStatus,
    this.instructions,
  });

  final String name;
  final String description;
  final String imagePath;
  final String price;
  final String? reviews;
  final String type;
  final String status;
  final String upselling;
  int quantity;
  String? instructions;
  final String cookingStatus;

  Map toJson(CartItemModel cartItemModel) {
    return {
      "name": cartItemModel.name,
      "description": cartItemModel.description,
      "imagePath": cartItemModel.imagePath,
      "price": cartItemModel.price,
      "reviews": cartItemModel.reviews,
      "type": cartItemModel.type,
      "status": cartItemModel.status,
      "upselling": cartItemModel.upselling,
      "quantity": cartItemModel.quantity,
      "instructions": cartItemModel.instructions
    };
  }
}
