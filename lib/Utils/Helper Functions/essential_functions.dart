import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/Utils/app_routes.dart';

import '../../MVVM/Models/RestaurantsModel/restaurants_model.dart';
import '../../MVVM/Models/Tables Model/tables_model.dart';
import '../../MVVM/View Model/Resturants View Model/resturants_view_model.dart';
import '../../MVVM/View Model/Tables View Model/tables_view_model.dart';
import '../../Widgets/custom_button.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/custom_text_field.dart';
import '../contants.dart';

class EssentialFunctions {
  void createRestaurantDialogue(
      BuildContext context, TextEditingController restaurantsController) {
    FilePickerResult? image;
    showDialog(
        context: context,
        builder: (context) {
          RestaurantsViewModel restaurantsViewModel =
              context.watch<RestaurantsViewModel>();
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
                                foregroundImage: AssetImage("/upload_logo.jpg"),
                              )),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "restaurants name"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: restaurantsController,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    restaurantsViewModel.loading
                        ? const CircularProgressIndicator.adaptive()
                        : CustomButton(
                            buttonColor: primaryColor,
                            text: "create",
                            textColor: kWhite,
                            function: () async {
                              if (restaurantsController.text.isEmpty ||
                                  image == null) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Make sure to upload a restaurants Logo and a Valid name");
                              } else {
                                final fileBytes = image!.files.single.bytes;

                                final fileName = image!.files.single.name;
                                await restaurantsViewModel
                                    .createrestaurants(
                                        restaurantsController.text,
                                        fileName,
                                        fileBytes!)
                                    .then((value) {
                                  restaurantsController.clear();
                                  if (restaurantsViewModel.modelError == null) {
                                    KRoutes.pop(context);
                                    Fluttertoast.showToast(
                                        msg: "restaurants created");
                                    restaurantsViewModel.setModelError(null);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Unable to create restaurants");
                                    restaurantsViewModel.setModelError(null);
                                  }
                                });
                              }
                            },
                          ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void createUpdateTable(BuildContext context, RestaurantModel? restaurantModel,
      TextEditingController tableController, TablesViewModel tablesViewModel,
      {bool update = false, TablesModel? table}) {
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(text: "Create Table"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: tableController,
                      suffixIcon: const Icon(Icons.table_bar),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Fill this field";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        buttonColor: primaryColor,
                        text: update ? "Update" : "Create",
                        textColor: kWhite,
                        function: () async {
                          if (tableController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Make sure to fill all fields");
                          } else {
                            await tablesViewModel
                                .createTables(tableController.text, "yaayyy",
                                    restaurantModel?.id ?? "")
                                .then((value) {
                              tableController.clear();
                              if (tablesViewModel.modelError == null) {
                                KRoutes.pop(context);
                                Fluttertoast.showToast(
                                    msg: "restaurants created");
                                tablesViewModel.setModelError(null);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Unable to create restaurants");
                                tablesViewModel.setModelError(null);
                              }
                            });
                          }
                        })
                  ],
                ),
              ),
            ),
          );
        });
  }
}
