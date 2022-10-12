import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/food_card.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';

import '../../../Utils/contants.dart';
import '../../../Widgets/custom_text.dart';
import '../../../Widgets/custom_text_field.dart';

class MenuPage extends StatefulWidget {
  final String resturantKey;
  final String categoryKey;
  final String categoryName;
  const MenuPage(
      {super.key,
      required this.resturantKey,
      required this.categoryKey,
      required this.categoryName});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController menuItemController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: widget.categoryName,
        appBar: AppBar(),
        widgets: const [],
        appBarHeight: 50,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showCustomDialog(context);
          },
          label: const CustomText(text: "Add Menu Item")),
      body: Center(
        child: FirebaseAnimatedList(
          query: DatabaseService.getsingleResturantsCategories(
            widget.resturantKey,
            widget.categoryKey,
            widget.categoryName,
          ),
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map foodItem = snapshot.value as Map;
            foodItem["key"] = snapshot.key;

            return CustomFoodCard(data: foodItem);
          },
        ),
      ),
    );
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormTextField(
                    controller: menuItemController,
                    suffixIcon: const Icon(Icons.shower_sharp),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                      buttonColor: primaryColor,
                      text: "create",
                      textColor: kWhite,
                      function: () async {
                        await DatabaseService.createCategoryItems(
                                widget.resturantKey,
                                widget.categoryKey,
                                widget.categoryName)
                            .then((value) => KRoutes.pop(context));
                      })
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    menuItemController.dispose();
    super.dispose();
  }
}
