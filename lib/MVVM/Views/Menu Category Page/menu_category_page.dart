import 'package:beamer/beamer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_alert.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_search.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_button.dart';

class MenuCategoryPage extends StatefulWidget {
  final String restaurantsKey;
  final String? tableKey;
  final String? name;
  final String? phone;
  const MenuCategoryPage({
    super.key,
    required this.restaurantsKey,
    this.tableKey,
    this.name,
    this.phone,
  });

  @override
  State<MenuCategoryPage> createState() => _MenuCategoryPageState();
}

class _MenuCategoryPageState extends State<MenuCategoryPage> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController controller = TextEditingController();

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
      floatingActionButton: widget.name != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                showCustomDialog(context);
              },
              label: const CustomText(
                text: "Create Category",
                color: kWhite,
              )),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                  StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child("restaurants")
                          .child(widget.restaurantsKey)
                          .child("menu")
                          .onValue,
                      builder:
                          (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        return menuCategoryView(snapshot);
                      }),
                ],
              ))),
    );
  }

  Widget menuCategoryView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Expanded(child: CustomLoader());
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Expanded(child: Center(child: Text("No categories Yet !!")));
    }
    Map allrestaurantsMenuCategories = snapshot.data!.snapshot.value as Map;
    List categoriesList = allrestaurantsMenuCategories.keys.toList();
    final suggestions =
        allrestaurantsMenuCategories.keys.toList().where((element) {
      final categoryTitle = allrestaurantsMenuCategories[element]
              ["categoryName"]
          .toString()
          .toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    categoriesList = suggestions;
    return Column(
      children: categoriesList.map((e) {
        Map category = allrestaurantsMenuCategories[e] as Map;
        category["key"] = e;

        return ListTile(
          title: CustomText(
            text: category["key"],
          ),
          onTap: () {
            if (widget.name != null) {
              Beamer.of(context).beamToNamed(
                  "/restaurants-menu-category-menu/${widget.restaurantsKey},${category["key"]},${widget.tableKey},${widget.name},${widget.phone}");
            } else {
              Beamer.of(context).beamToNamed(
                  "/restaurants-menu-category-menu/${widget.restaurantsKey},${category["key"]}");
            }
          },
        );
      }).toList(),
    );
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(scrollable: true,
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
                                widget.restaurantsKey, categoryController.text)
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
