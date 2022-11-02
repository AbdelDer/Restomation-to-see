import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/add_to_cart.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../Repo/Storage Service/storage_service.dart';

class CustomFoodCard extends StatelessWidget {
  final Map data;
  final String? name;
  final String? phone;
  final String restaurantsKey;
  final String categoryKey;
  final VoidCallback edit;
  final VoidCallback delete;
  const CustomFoodCard(
      {super.key,
      required this.data,
      required this.name,
      required this.phone,
      required this.restaurantsKey,
      required this.categoryKey,
      required this.edit,
      required this.delete});

  @override
  Widget build(BuildContext context) {
    final ref = StorageService.storage.ref().child(data["image"]);
    bool isActive = false;
    if (data["status"] == "available") {
      isActive = true;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
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
                    "₹${data["price"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${data["type"]}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomText(
                    text: data["description"],
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder(
                      future: ref.getDownloadURL(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
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
                                    image: NetworkImage(snapshot.data!),
                                    fit: BoxFit.cover)),
                          );
                        }
                        return Container(
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
                          ),
                        );
                      }),
                  if (name != null)
                    Positioned(
                        bottom: 5,
                        child: AddToCart(
                          foodData: data,
                        ))
                ],
              ),
            )
          ],
        ),
        if (name == null)
          StatefulBuilder(builder: (context, refreshState) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  color: primaryColor,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  onPressed: edit,
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  color: Colors.red,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: delete,
                ),
                const SizedBox(
                  width: 10,
                ),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    if (value == true) {
                      DatabaseService.db
                          .ref()
                          .child("restaurants")
                          .child(restaurantsKey)
                          .child("menu")
                          .child(categoryKey)
                          .child("items")
                          .child(data["key"])
                          .update({"status": "available"});
                    } else {
                      DatabaseService.db
                          .ref()
                          .child("restaurants")
                          .child(restaurantsKey)
                          .child("menu")
                          .child(categoryKey)
                          .child("items")
                          .child(data["key"])
                          .update({"status": "unavailable"});
                    }
                  },
                ),
              ],
            );
          })
      ],
    );
  }
}
