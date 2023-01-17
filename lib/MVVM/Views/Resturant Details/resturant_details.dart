import 'package:flutter/material.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';

import '../../Models/RestaurantsModel/restaurants_model.dart';
import 'package:go_router/go_router.dart';

class RestaurantsDetailPage extends StatelessWidget {
  final RestaurantModel restaurantModel;
  const RestaurantsDetailPage({
    super.key,
    required this.restaurantModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: restaurantModel.name ?? "No name",
          appBar: AppBar(),
          widgets: const [],
          automaticallyImplyLeading: true,
          appBarHeight: 50),
      body: Center(
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              {
                "name": "menu",
                "image":
                    "https://thumbs.dreamstime.com/b/vintage-frames-gold-restaurant-bar-food-drinks-cafe-menu-black-background-vector-illustrtor-badge-border-branding-bundle-186691349.jpg",
                "page": () {
                  context.push("/menu",
                      extra: RestaurantModel.toJson(restaurantModel));
                }
              },
              {
                "name": "Tables",
                "image":
                    "https://s.alicdn.com/@sc04/kf/H436ab8e73d1244f1a216e047dc16421cd.jpg",
                "page": () {
                  context.push("/tables",
                      extra: RestaurantModel.toJson(restaurantModel));
                }
              },
              {
                "name": "Staff",
                "image":
                    "https://static.vecteezy.com/system/resources/thumbnails/006/903/981/small_2x/restaurant-waiter-serve-dish-to-customer-free-vector.jpg",
                "page": () {
                  context.push("/staff",
                      extra: RestaurantModel.toJson(restaurantModel));
                }
              },
              {
                "name": "Orders",
                "image":
                    "https://static.vecteezy.com/system/resources/previews/009/322/978/non_2x/illustration-of-food-service-via-mobile-application-free-vector.jpg",
                "page": () {
                  context.push("/orders",
                      extra: RestaurantModel.toJson(restaurantModel));
                }
              },
              {
                "name": "Admins",
                "image":
                    "https://static.vecteezy.com/system/resources/thumbnails/006/017/842/small_2x/customer-service-icon-user-with-laptop-computer-and-headphone-illustration-free-vector.jpg",
                "page": () {
                  context.push("/admins",
                      extra: RestaurantModel.toJson(restaurantModel));
                }
              },
            ]
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: GestureDetector(
                        onTap: e["page"] as VoidCallback,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 100,
                              foregroundImage:
                                  NetworkImage(e["image"].toString()),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(e["name"].toString())
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
