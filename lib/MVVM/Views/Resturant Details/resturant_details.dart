import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Views/Menu%20Category%20Page/menu_category_page.dart';
import 'package:restomation/MVVM/Views/OrderScreen/order_screen.dart';
import 'package:restomation/MVVM/Views/Staff%20Category%20Page/staff_category_page.dart';
import 'package:restomation/MVVM/Views/Tables%20Page/tables_view.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';

class ResturantDetailPage extends StatelessWidget {
  final String resturantName;
  final String resturantKey;
  const ResturantDetailPage(
      {super.key, required this.resturantName, required this.resturantKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: resturantName,
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
                  KRoutes.push(
                      context,
                      MenuCategoryPage(
                        resturantKey: resturantKey,
                        resturantName: resturantName,
                      ));
                }
              },
              {
                "name": "Tables",
                "image":
                    "https://s.alicdn.com/@sc04/kf/H436ab8e73d1244f1a216e047dc16421cd.jpg",
                "page": () {
                  KRoutes.push(
                      context,
                      TablesPage(
                        resturantKey: resturantKey,
                      ));
                }
              },
              {
                "name": "Staff",
                "image":
                    "https://static.vecteezy.com/system/resources/thumbnails/006/903/981/small_2x/restaurant-waiter-serve-dish-to-customer-free-vector.jpg",
                "page": () {
                  KRoutes.push(
                      context,
                      StaffCategoryPage(
                        resturantKey: resturantKey,
                        resturantName: resturantName,
                      ));
                }
              },
              {
                "name": "Orders",
                "image":
                    "https://static.vecteezy.com/system/resources/previews/009/322/978/non_2x/illustration-of-food-service-via-mobile-application-free-vector.jpg",
                "page": () {
                  KRoutes.push(
                      context,
                      OrderScreen(
                        resturantKey: resturantKey,
                           resturantName: resturantName,
                      ));
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
