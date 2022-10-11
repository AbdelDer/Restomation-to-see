import 'package:flutter/material.dart';
import 'package:restomation/Widgets/add_to_cart.dart';

class CustomFoodCard extends StatelessWidget {
  final Map data;
  const CustomFoodCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.adjust_rounded,
                color: Colors.green,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                data["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                data["price"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: data["description"],
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const TextSpan(
                    text: " more",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black))
              ]))
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 170,
                height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 0),
                          spreadRadius: 2,
                          blurRadius: 2,
                          color: Colors.black12)
                    ],
                    image: DecorationImage(
                        image: NetworkImage(data["image"]), fit: BoxFit.cover)),
              ),
              const Positioned(bottom: 5, child: AddToCart())
            ],
          ),
        )
      ],
    );
  }
}
