import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/food_card.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_alert.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_cart_badge_icon.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_search.dart';

import '../../../Utils/contants.dart';
import '../../../Widgets/custom_text.dart';
import '../../../Widgets/custom_text_field.dart';

class MenuPage extends StatefulWidget {
  final String restaurantsKey;
  final String categoryKey;
  final String? tableKey;
  final String? name;
  final String? phone;
  const MenuPage(
      {super.key,
      required this.restaurantsKey,
      required this.categoryKey,
      this.tableKey,
      this.name,
      this.phone});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController menuItemNameController = TextEditingController();
  final TextEditingController menuItemPriceController = TextEditingController();
  final TextEditingController menuItemDescriptionController =
      TextEditingController();
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
                text: "Add Menu Item",
                color: kWhite,
              )),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: widget.categoryKey,
                        fontsize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                      if (widget.name != null)
                        CustomCartBadgeIcon(
                          tableKey: widget.tableKey!,
                          restaurantsKey: widget.restaurantsKey,
                          customer: widget.name!,
                          restaurantsName: widget.restaurantsKey,
                        )
                    ],
                  ),
                  CustomSearch(
                    controller: controller,
                    searchText: "Search Items",
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
                          .child(widget.categoryKey)
                          .child("items")
                          .onValue,
                      builder:
                          (context, AsyncSnapshot<DatabaseEvent?> snapshot) {
                        return menuItemsView(snapshot);
                      }),
                ],
              ))),
    );
  }

  Widget menuItemsView(AsyncSnapshot<DatabaseEvent?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Expanded(child: CustomLoader());
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return Expanded(
          child: Center(
              child: CustomText(
                  text: "No ${widget.categoryKey} items added yet !!")));
    }
    Map allrestaurantsMenuItems = snapshot.data!.snapshot.value as Map;
    List categoriesListItems = allrestaurantsMenuItems.keys.toList();
    final suggestions = allrestaurantsMenuItems.keys.toList().where((element) {
      final categoryTitle =
          allrestaurantsMenuItems[element]["name"].toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    categoriesListItems = suggestions;
    return Column(
      children: categoriesListItems.map((e) {
        Map foodItem = allrestaurantsMenuItems[e] as Map;
        foodItem["key"] = e;

        return Slidable(
            endActionPane: _actionPane(foodItem),
            child: CustomFoodCard(
              data: foodItem,
              name: widget.name,
              phone: widget.phone,
            ));
      }).toList(),
    );
  }

  void showCustomDialog(BuildContext context,
      {bool update = false, Map? itemData}) {
    FilePickerResult? image;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, refreshState) {
            return AlertDialog(
              scrollable: true,
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(text: "Upload Image"),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                        onTap: () async {
                          image = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            allowedExtensions: [
                              "png",
                              "jpg",
                            ],
                          );
                          if (image == null) {
                            Fluttertoast.showToast(msg: "No file selected");
                          } else {
                            refreshState(() {});
                          }
                        },
                        child: image != null
                            ? CircleAvatar(
                                radius: 100,
                                backgroundColor: kWhite,
                                foregroundImage:
                                    MemoryImage(image!.files.single.bytes!),
                              )
                            : const CircleAvatar(
                                radius: 100,
                                backgroundColor: kWhite,
                                foregroundImage: NetworkImage(
                                    "https://cdn.dribbble.com/users/1965140/screenshots/9776931/dribbble_75_4x.png"),
                              )),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "Item name"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: menuItemNameController,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "Item price"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: menuItemPriceController,
                      keyboardtype: TextInputType.number,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "Short description"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: menuItemDescriptionController,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        buttonColor: primaryColor,
                        text: update ? "Update" : "create",
                        textColor: kWhite,
                        function: () async {
                          if (image == null ||
                              menuItemNameController.text.isEmpty ||
                              menuItemPriceController.text.isEmpty ||
                              menuItemDescriptionController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg:
                                    "Make sure to fill all fields and upload an image of the item");
                          } else {
                            final fileBytes = image!.files.single.bytes;
                            final fileName = image!.files.single.name;
                            if (update) {
                              Map item = {
                                "name": menuItemNameController.text,
                                "price": menuItemPriceController.text,
                                "image":
                                    "restaurants/${widget.restaurantsKey}/menu/${widget.categoryKey}/$fileName",
                                "description":
                                    menuItemDescriptionController.text,
                                "reviews": itemData!["reviews"],
                                "rating": itemData["rating"]
                              };
                              Alerts.customLoadingAlert(context);
                              await DatabaseService.updateCategoryItems(
                                      widget.restaurantsKey,
                                      widget.categoryKey,
                                      itemData["key"],
                                      widget.restaurantsKey,
                                      widget.categoryKey,
                                      itemData["image"],
                                      fileName,
                                      item,
                                      fileBytes!)
                                  .then((value) {
                                menuItemNameController.clear();
                                menuItemDescriptionController.clear();
                                menuItemPriceController.clear();
                                KRoutes.pop(context);
                                return KRoutes.pop(context);
                              });
                            } else {
                              Map item = {
                                "name": menuItemNameController.text,
                                "price": menuItemPriceController.text,
                                "image":
                                    "restaurants/${widget.restaurantsKey}/menu/${widget.categoryKey}/$fileName",
                                "description":
                                    menuItemDescriptionController.text,
                                "reviews": "0",
                                "rating": "0"
                              };
                              Alerts.customLoadingAlert(context);
                              await DatabaseService.createCategoryItems(
                                      widget.restaurantsKey,
                                      widget.categoryKey,
                                      widget.restaurantsKey,
                                      widget.categoryKey,
                                      fileName,
                                      item,
                                      fileBytes!)
                                  .then((value) {
                                menuItemNameController.clear();
                                menuItemDescriptionController.clear();
                                menuItemPriceController.clear();
                                KRoutes.pop(context);
                                return KRoutes.pop(context);
                              });
                            }
                          }
                        }),
                  ],
                ),
              ),
            );
          });
        });
  }

  ActionPane _actionPane(Map foodItem) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          onPressed: (context) {
            menuItemNameController.text = foodItem["name"];
            menuItemPriceController.text = foodItem["price"];
            menuItemDescriptionController.text = foodItem["description"];
            showCustomDialog(context, update: true, itemData: foodItem);
          },
          backgroundColor: const Color(0xFF21B7CA),
          foregroundColor: Colors.white,
          icon: Icons.share,
          label: 'Edit',
        ),
        SlidableAction(
          onPressed: (context) {
            Alerts.customLoadingAlert(context);
            DatabaseService.storage.ref().child(foodItem["image"]).delete();
            DatabaseService.db
                .ref()
                .child("restaurants")
                .child(widget.restaurantsKey)
                .child("menu")
                .child(widget.categoryKey)
                .child(widget.categoryKey)
                .child(foodItem["key"])
                .remove();
            KRoutes.pop(context);
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ],
    );
  }

  @override
  void dispose() {
    menuItemNameController.dispose();
    menuItemPriceController.dispose();
    menuItemDescriptionController.dispose();
    controller.dispose();
    super.dispose();
  }
}
