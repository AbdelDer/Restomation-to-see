import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/menu_page.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_alert.dart';
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
  final TextEditingController controller = TextEditingController();
  Map allResturantsMenuCategories = {};
  @override
  void initState() {
    getAllResturantsMenuCategories();
    super.initState();
  }

  getAllResturantsMenuCategories() {
    DatabaseReference ordersCountRef = FirebaseDatabase.instance
        .ref()
        .child("resturants")
        .child(widget.resturantKey)
        .child("menu");
    ordersCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      data as Map?;
      setState(() {
        if (data != null) {
          allResturantsMenuCategories = data;
        }
      });
    });
  }

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
          label: const CustomText(
            text: "Create Category",
            color: kWhite,
          )),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20), child: menuCategoryView())),
    );
  }

  Widget menuCategoryView() {
    if (allResturantsMenuCategories.keys.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Text("No categories Yet !!")],
      );
    }
    List categoriesList = allResturantsMenuCategories.keys.toList();
    final suggestions =
        allResturantsMenuCategories.keys.toList().where((element) {
      final categoryTitle = allResturantsMenuCategories[element]["categoryName"]
          .toString()
          .toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    categoriesList = suggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Select a category :",
          fontsize: 35,
          fontWeight: FontWeight.bold,
        ),
        CustomSearch(
          controller: controller,
          searchText: "Search Categories",
          function: () {
            setState(() {});
          },
        ),
        Column(
          children: categoriesList.map((e) {
            Map category = allResturantsMenuCategories[e] as Map;
            category["key"] = e;

            return ListTile(
              title: CustomText(
                text: category["categoryName"],
              ),
              onTap: () {
                KRoutes.push(
                    context,
                    MenuPage(
                      resturantKey: widget.resturantKey,
                      categoryKey: category["key"],
                      categoryName: category["categoryName"],
                      resturantName: widget.resturantName,
                    ));
              },
            );
          }).toList(),
        )
      ],
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
                        Alerts.customLoadingAlert(context);
                        await DatabaseService.createCategory(
                                widget.resturantKey, categoryController.text)
                            .then((value) {
                          KRoutes.pop(context);
                          return KRoutes.pop(context);
                        });
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
    controller.dispose();
    super.dispose();
  }
}
