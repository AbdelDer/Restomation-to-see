import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/menu_page.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_search.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_button.dart';

class MenuCategoryPage extends StatefulWidget {
  final String resturantKey;
  final String resturantName;
  const MenuCategoryPage(
      {super.key, required this.resturantKey, required this.resturantName});

  @override
  State<MenuCategoryPage> createState() => _MenuCategoryPageState();
}

class _MenuCategoryPageState extends State<MenuCategoryPage> {
  final TextEditingController categoryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "",
        appBar: AppBar(),
        widgets: const [],
        appBarHeight: 50,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showCustomDialog(context);
          },
          label: const CustomText(text: "Create Category")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: "Select a category :",
              fontsize: 35,
              fontWeight: FontWeight.bold,
            ),
            const CustomSearch(),
            Expanded(
              child: FirebaseAnimatedList(
                query: DatabaseService.getResturantsCategories(
                    widget.resturantKey),
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  Map category = snapshot.value as Map;
                  category["key"] = snapshot.key;

                  return ListTile(
                    title: CustomText(
                      text: category["categoryName"],
                    ),
                    onTap: () {
                      KRoutes.push(
                          context,
                          MenuPage(
                            resturantKey: widget.resturantKey,
                            categoryKey: snapshot.key!,
                            categoryName: category["categoryName"],
                            resturantName: widget.resturantName,
                          ));
                    },
                  );
                },
              ),
            ),
          ],
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
                  const CustomText(text: "Create Category"),
                  const SizedBox(
                    height: 10,
                  ),
                  FormTextField(
                    controller: categoryController,
                    suffixIcon: const Icon(Icons.shower_sharp),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                      buttonColor: primaryColor,
                      text: "create",
                      textColor: kWhite,
                      function: () async {
                        await DatabaseService.createCategory(
                                widget.resturantKey, categoryController.text)
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
    categoryController.dispose();
    super.dispose();
  }
}
