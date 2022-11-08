import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/food_card.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_alert.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_drop_down.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_search.dart';

import '../../../Utils/contants.dart';
import '../../../Widgets/custom_text.dart';
import '../../../Widgets/custom_text_field.dart';

class MenuPage extends StatefulWidget {
  final BuildContext previousScreenContext;
  final String restaurantsKey;
  final String categoryKey;
  final String? tableKey;
  final String? name;
  final String? phone;
  final String? isTableClean;
  const MenuPage(
      {super.key,
      required this.restaurantsKey,
      required this.categoryKey,
      this.tableKey,
      this.name,
      this.phone,
      this.isTableClean,
      required this.previousScreenContext});

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
      floatingActionButton: widget.name != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                showCustomDialog(widget.previousScreenContext);
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
                  CustomSearch(
                    controller: controller,
                    searchText: "Search Items",
                    function: () {
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: StreamBuilder(
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
                  ),
                ],
              ))),
    );
  }

  Widget menuItemsView(AsyncSnapshot<DatabaseEvent?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CustomLoader());
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return Center(
          child:
              CustomText(text: "No ${widget.categoryKey} items added yet !!"));
    }
    Map allrestaurantsMenuItems = snapshot.data!.snapshot.value as Map;
    List categoriesListItems = allrestaurantsMenuItems.keys.toList();

    List suggestions = allrestaurantsMenuItems.keys.toList().where((element) {
      final categoryTitle =
          allrestaurantsMenuItems[element]["name"].toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    if (widget.name != null) {
      suggestions = allrestaurantsMenuItems.keys.toList().where((element) {
        final categoryTitle =
            allrestaurantsMenuItems[element]["status"].toString().toLowerCase();
        const status = "available";
        return categoryTitle == status;
      }).toList();
    }
    categoriesListItems = suggestions;

    return ListView.builder(
      itemCount: categoriesListItems.length,
      itemBuilder: (context, index) {
        String key = categoriesListItems[index];
        Map foodItem = allrestaurantsMenuItems[key] as Map;
        foodItem["key"] = key;

        return CustomFoodCard(
          data: foodItem,
          name: widget.name,
          phone: widget.phone,
          categoryKey: widget.categoryKey,
          restaurantsKey: widget.restaurantsKey,
          delete: deleteItem(foodItem),
          edit: editItem(foodItem),
        );
      },
    );
  }

  void showCustomDialog(BuildContext context,
      {bool update = false, Map? itemData}) {
    FilePickerResult? image;
    Reference? isExisting;
    showDialog(
        context: widget.previousScreenContext,
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
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomButton(
                                      buttonColor: primaryColor,
                                      text: "Select existing images",
                                      textColor: kWhite,
                                      function: () {
                                        KRoutes.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                title: const CustomText(
                                                    text: "Existing Images :"),
                                                content: SizedBox(
                                                  height: 500,
                                                  width: 500,
                                                  child: StreamBuilder(
                                                    stream: DatabaseService
                                                        .storage
                                                        .ref()
                                                        .child("restaurants")
                                                        .child(widget
                                                            .restaurantsKey)
                                                        .child("menu")
                                                        .child(
                                                            widget.categoryKey)
                                                        .listAll()
                                                        .asStream(),
                                                    builder: (context,
                                                        AsyncSnapshot<
                                                                ListResult>
                                                            snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const Center(
                                                            child:
                                                                CircularProgressIndicator());
                                                      }
                                                      if (snapshot.hasError) {
                                                        return const Text(
                                                            "error");
                                                      }
                                                      List<Reference>
                                                          allImages = snapshot
                                                              .data!.items
                                                              .toList();
                                                      return GridView.builder(
                                                        itemCount:
                                                            allImages.length,
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    2,
                                                                mainAxisSpacing:
                                                                    10,
                                                                crossAxisSpacing:
                                                                    10),
                                                        itemBuilder:
                                                            (context, index) {
                                                          return FutureBuilder(
                                                              future: allImages[
                                                                      index]
                                                                  .getDownloadURL(),
                                                              builder: (BuildContext
                                                                      context,
                                                                  AsyncSnapshot
                                                                      snapshot) {
                                                                if (snapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .done) {
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      KRoutes.pop(
                                                                          context);
                                                                      refreshState(
                                                                          () {
                                                                        isExisting =
                                                                            allImages[index];
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(15),
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                                offset: Offset(0, 0),
                                                                                spreadRadius: 2,
                                                                                blurRadius: 2,
                                                                                color: Colors.black12)
                                                                          ],
                                                                          image: DecorationImage(image: NetworkImage(snapshot.data!), fit: BoxFit.cover)),
                                                                    ),
                                                                  );
                                                                }
                                                                return Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                          offset: Offset(0,
                                                                              0),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              2,
                                                                          color:
                                                                              Colors.black12)
                                                                    ],
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ));
                                          },
                                        );
                                      }),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomButton(
                                      buttonColor: primaryColor,
                                      text: "Upload",
                                      textColor: kWhite,
                                      function: () async {
                                        image =
                                            await FilePicker.platform.pickFiles(
                                          allowMultiple: false,
                                          type: FileType.custom,
                                          allowedExtensions: [
                                            "png",
                                            "jpg",
                                          ],
                                        ).then((value) {
                                          if (value == null) {
                                            Fluttertoast.showToast(
                                                msg: "No file selected");
                                          } else {
                                            KRoutes.pop(context);
                                            refreshState(() {});
                                          }
                                          return value;
                                        });
                                      }),
                                ],
                              ),
                            ),
                          );
                        },
                        child: isExisting != null
                            ? FutureBuilder(
                                future: isExisting!.getDownloadURL(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return CircleAvatar(
                                      radius: 100,
                                      backgroundColor: kWhite,
                                      foregroundImage:
                                          NetworkImage(snapshot.data),
                                    );
                                  }
                                  return const CircleAvatar(
                                    radius: 100,
                                    backgroundColor: kGrey,
                                  );
                                })
                            : image != null
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
                    if (update == false) const CustomText(text: "Item name"),
                    if (update == false)
                      const SizedBox(
                        height: 10,
                      ),
                    if (update == false)
                      FormTextField(
                        controller: menuItemNameController,
                        suffixIcon: const Icon(Icons.shower_sharp),
                      ),
                    if (update == false)
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
                      height: 10,
                    ),
                    const ListDropDown(),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        buttonColor: primaryColor,
                        text: update ? "Update" : "create",
                        textColor: kWhite,
                        function: () async {
                          createItem(update, image, itemData, isExisting);
                        }),
                  ],
                ),
              ),
            );
          });
        });
  }

  Future<void> createItem(bool update, FilePickerResult? image, Map? itemData,
      Reference? isExisting) async {
    if (update == true) {
      if (menuItemNameController.text.isEmpty ||
          menuItemPriceController.text.isEmpty ||
          menuItemDescriptionController.text.isEmpty) {
        Fluttertoast.showToast(
            msg:
                "Make sure to fill all fields and upload an image of the item");
      } else {
        String? fileName;
        Uint8List? fileBytes;
        if (image != null) {
          fileBytes = image.files.single.bytes;
          fileName = image.files.single.name;
        }
        Map<String, Object?> item = {
          "name": menuItemNameController.text,
          "price": menuItemPriceController.text,
          "image": isExisting != null
              ? isExisting.fullPath
              : image == null
                  ? itemData!["image"]
                  : "restaurants/${widget.restaurantsKey}/menu/${widget.categoryKey}/$fileName",
          "description": menuItemDescriptionController.text,
          "type": selectedMenuOption,
          "status": itemData!["status"],
          "reviews": itemData["reviews"],
          "rating": itemData["rating"]
        };
        Alerts.customLoadingAlert(widget.previousScreenContext);
        await DatabaseService.updateCategoryItems(widget.restaurantsKey,
                widget.categoryKey, itemData["key"], itemData["image"],
                fileName: fileName,
                item: item,
                bytes: fileBytes,
                isExsiting: isExisting != null ? true : false)
            .then((value) {
          KRoutes.pop(widget.previousScreenContext);
          return KRoutes.pop(widget.previousScreenContext);
        });
      }
    } else {
      if ((image == null && isExisting == null) ||
          menuItemNameController.text.isEmpty ||
          menuItemPriceController.text.isEmpty ||
          menuItemDescriptionController.text.isEmpty) {
        Fluttertoast.showToast(
            msg:
                "Make sure to fill all fields and upload an image of the item");
      } else {
        String? fileName;
        Uint8List? fileBytes;
        if (image != null) {
          fileBytes = image.files.single.bytes;
          fileName = image.files.single.name;
        }
        Map<String, Object?> item = {
          "name": menuItemNameController.text,
          "price": menuItemPriceController.text,
          "image": isExisting != null
              ? isExisting.fullPath
              : "restaurants/${widget.restaurantsKey}/menu/${widget.categoryKey}/$fileName",
          "description": menuItemDescriptionController.text,
          "type": selectedMenuOption,
          "status": "available",
          "reviews": "0",
          "rating": "0"
        };
        Alerts.customLoadingAlert(context);
        await DatabaseService.createCategoryItems(widget.restaurantsKey,
                widget.categoryKey, widget.restaurantsKey,
                fileName: fileName,
                item: item,
                bytes: fileBytes,
                isExsiting: isExisting != null ? true : false)
            .then((value) {
          KRoutes.pop(widget.previousScreenContext);
          return KRoutes.pop(widget.previousScreenContext);
        });
      }
    }
  }

  VoidCallback deleteItem(Map foodItem) {
    return () {
      Alerts.customLoadingAlert(context);
      DatabaseService.db
          .ref()
          .child("restaurants")
          .child(widget.restaurantsKey)
          .child("menu")
          .child(widget.categoryKey)
          .child("items")
          .child(foodItem["key"])
          .remove();
      KRoutes.pop(context);
    };
  }

  VoidCallback editItem(Map foodItem) {
    return () {
      menuItemNameController.text = foodItem["name"];
      menuItemPriceController.text = foodItem["price"];
      menuItemDescriptionController.text = foodItem["description"];
      showCustomDialog(context, update: true, itemData: foodItem);
    };
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
