import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/menu_page.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_button.dart';

class CategoryPage extends StatefulWidget {
  final String resturantKey;
  const CategoryPage({super.key, required this.resturantKey});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController categoryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "Categories",
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
      body: Center(
        child: FirebaseAnimatedList(
          query: DatabaseService.getResturantsCategories(widget.resturantKey),
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map category = snapshot.value as Map;
            category["key"] = snapshot.key;

            return GestureDetector(
              onTap: () {
                KRoutes.push(
                    context,
                    MenuPage(
                        resturantKey: widget.resturantKey,
                        categoryKey: snapshot.key!,
                        categoryName: category["categoryName"]));
              },
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey.shade300,
                    child: CustomText(
                      text: category["categoryName"],
                    ),
                  )),
            );
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
                    controller: categoryController,
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
