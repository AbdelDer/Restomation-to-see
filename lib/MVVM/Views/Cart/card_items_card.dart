import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class CartItemsCard extends StatelessWidget {
  final Map data;
  final String? name;
  final String? phone;
  final String restaurantsKey;
  final String categoryName;
  final VoidCallback edit;
  final VoidCallback delete;
  const CartItemsCard(
      {super.key,
      required this.data,
      this.name,
      this.phone,
      required this.restaurantsKey,
      required this.categoryName,
      required this.edit,
      required this.delete});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
