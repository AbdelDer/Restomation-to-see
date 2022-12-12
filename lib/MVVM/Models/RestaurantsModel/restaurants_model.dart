import 'dart:convert';

RestaurantModel restaurantModelFromJson(String str) =>
    RestaurantModel.fromJson(json.decode(str));

String restaurantModelToJson(RestaurantModel data) =>
    json.encode(data.toJson());

class RestaurantModel {
  RestaurantModel({
    required this.name,
    required this.imagePath,
  });

  final String? name;
  final String? imagePath;

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      RestaurantModel(
        name: json["name"],
        imagePath: json["image_path"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image_path": imagePath,
      };
}
