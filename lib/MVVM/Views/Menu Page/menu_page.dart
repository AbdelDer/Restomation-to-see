import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/food_card.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_search.dart';

import '../../../Utils/contants.dart';
import '../../../Widgets/custom_text.dart';
import '../../../Widgets/custom_text_field.dart';

class MenuPage extends StatefulWidget {
  final String resturantKey;
  final String resturantName;
  final String categoryKey;
  final String categoryName;
  const MenuPage(
      {super.key,
      required this.resturantKey,
      required this.categoryKey,
      required this.categoryName,
      required this.resturantName});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController menuItemNameController = TextEditingController();
  final TextEditingController menuItemPriceController = TextEditingController();
  final TextEditingController menuItemDescriptionController =
      TextEditingController();
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
          label: const CustomText(text: "Add Menu Item")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomText(
              text: widget.categoryName,
              fontsize: 35,
              fontWeight: FontWeight.bold,
            ),
            const CustomSearch(),
            Expanded(
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

                  return Slidable(
                      endActionPane: _actionPane(foodItem),
                      child: CustomFoodCard(data: foodItem));
                },
              ),
            ),
          ],
        ),
      ),
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
                                    "resturants/${widget.resturantName}/menu/${widget.categoryName}/$fileName",
                                "description":
                                    menuItemDescriptionController.text,
                                "reviews": itemData!["reviews"],
                                "rating": itemData["rating"]
                              };
                              await DatabaseService.updateCategoryItems(
                                      widget.resturantKey,
                                      widget.categoryKey,
                                      itemData["key"],
                                      widget.resturantName,
                                      widget.categoryName,
                                      itemData["image"],
                                      fileName,
                                      item,
                                      fileBytes!)
                                  .then((value) {
                                menuItemNameController.clear();
                                menuItemDescriptionController.clear();
                                menuItemPriceController.clear();
                                return KRoutes.pop(context);
                              });
                            } else {
                              Map item = {
                                "name": menuItemNameController.text,
                                "price": menuItemPriceController.text,
                                "image":
                                    "resturants/${widget.resturantName}/menu/${widget.categoryName}/$fileName",
                                "description":
                                    menuItemDescriptionController.text,
                                "reviews": "0",
                                "rating": "0"
                              };
                              await DatabaseService.createCategoryItems(
                                      widget.resturantKey,
                                      widget.categoryKey,
                                      widget.resturantName,
                                      widget.categoryName,
                                      fileName,
                                      item,
                                      fileBytes!)
                                  .then((value) {
                                menuItemNameController.clear();
                                menuItemDescriptionController.clear();
                                menuItemPriceController.clear();
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
            DatabaseService.storage.ref().child(foodItem["image"]).delete();
            DatabaseService.db
                .ref()
                .child("resturants")
                .child(widget.resturantKey)
                .child("menu")
                .child(widget.categoryKey)
                .child(widget.categoryName)
                .child(foodItem["key"])
                .remove();
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
    super.dispose();
  }
}
