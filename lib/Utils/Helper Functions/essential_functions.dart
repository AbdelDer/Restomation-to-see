import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/View%20Model/Category%20View%20Model.dart/category_view_model.dart';
import 'package:restomation/Utils/app_routes.dart';

import '../../MVVM/Models/RestaurantsModel/restaurants_model.dart';
import '../../MVVM/Models/Tables Model/tables_model.dart';
import '../../MVVM/View Model/Admin View Model.dart/admin_view_model.dart';
import '../../MVVM/View Model/Resturants View Model/resturants_view_model.dart';
import '../../MVVM/View Model/Staff View Model/staff_view_model.dart';
import '../../MVVM/View Model/Tables View Model/tables_view_model.dart';
import '../../Widgets/custom_button.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/custom_text_field.dart';
import '../contants.dart';

class EssentialFunctions {
  void createRestaurantDialogue(BuildContext context, TextEditingController restaurantsController) {
    FilePickerResult? image;
    showDialog(
        context: context,
        builder: (context) {
          RestaurantsViewModel restaurantsViewModel = context.watch<RestaurantsViewModel>();
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
                                foregroundImage: MemoryImage(image!.files.single.bytes!),
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
                              if (restaurantsController.text.isEmpty || image == null) {
                                Fluttertoast.showToast(msg: "Make sure to upload a restaurants Logo and a Valid name");
                              } else {
                                final fileBytes = image!.files.single.bytes;

                                final fileName = image!.files.single.name;
                                await restaurantsViewModel.createrestaurants(restaurantsController.text, fileName, fileBytes!).then((value) {
                                  restaurantsController.clear();
                                  if (restaurantsViewModel.modelError == null) {
                                    KRoutes.pop(context);
                                    Fluttertoast.showToast(msg: "restaurants created");
                                    restaurantsViewModel.setModelError(null);
                                  } else {
                                    Fluttertoast.showToast(msg: "Unable to create restaurants");
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

  void createUpdateTable(
      BuildContext context, RestaurantModel? restaurantModel, TextEditingController tableController, TablesViewModel tablesViewModel,
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
                            Fluttertoast.showToast(msg: "Make sure to fill all fields");
                          } else {
                            await tablesViewModel.createTables(tableController.text, "yaayyy", restaurantModel?.id ?? "").then((value) {
                              tableController.clear();
                              if (tablesViewModel.modelError == null) {
                                KRoutes.pop(context);
                                Fluttertoast.showToast(msg: "restaurants created");
                                tablesViewModel.setModelError(null);
                              } else {
                                Fluttertoast.showToast(msg: "Unable to create restaurants");
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

  void createStaffDialog(
    BuildContext context,
    RestaurantModel restaurantModel,
    TextEditingController personNameController,
    TextEditingController personPhoneController,
    TextEditingController personEmailController,
    TextEditingController personPasswordController, {
    bool update = false,
  }) {
    String selectedValue = "waiter";
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, refreshState) {
            StaffViewModel staffViewModel = context.watch<StaffViewModel>();
            return AlertDialog(
              scrollable: true,
              content: SizedBox(
                width: 300,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomText(text: "Person's name"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: personNameController,
                        suffixIcon: const Icon(Icons.person),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomText(text: "Person's phone"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: personPhoneController,
                        keyboardtype: TextInputType.number,
                        maxLength: 10,
                        suffixIcon: const Icon(Icons.phone),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          if (value.length < 10) {
                            return "Number should not be less than 10 digits";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomText(text: "Person's email"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: personEmailController,
                        suffixIcon: const Icon(Icons.email),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          if (!value.contains("@") || !value.contains(".")) {
                            return "Enter a valid Email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomText(text: "Person's Password"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: personPasswordController,
                        isPass: true,
                        suffixIcon: const Icon(Icons.visibility),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          if (value.length < 6) {
                            return "Password should not be less than 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButton(
                            buttonColor: selectedValue == "waiter" ? primaryColor : kGrey,
                            text: "Waiter",
                            textColor: kWhite,
                            function: () {
                              refreshState(() {
                                selectedValue = "waiter";
                              });
                            },
                            width: 130,
                            height: 40,
                          ),
                          CustomButton(
                            buttonColor: selectedValue == "cook" ? primaryColor : kGrey,
                            text: "Cook",
                            textColor: kWhite,
                            function: () {
                              refreshState(() {
                                selectedValue = "cook";
                              });
                            },
                            width: 130,
                            height: 40,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      staffViewModel.loading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              buttonColor: primaryColor,
                              text: update ? "Update" : "create",
                              textColor: kWhite,
                              function: () async {
                                if (formKey.currentState!.validate()) {
                                  if (update) {
                                  } else {
                                    staffViewModel.setModelError(null);
                                    await staffViewModel
                                        .createStaff(
                                            personNameController.text,
                                            personEmailController.text,
                                            personPhoneController.text,
                                            restaurantModel.id ?? "",
                                            restaurantModel.name ?? "",
                                            selectedValue.toLowerCase(),
                                            personPasswordController.text)
                                        .then((value) {
                                      if (staffViewModel.modelError != null) {
                                        Fluttertoast.showToast(msg: staffViewModel.modelError!.errorResponse.toString());
                                        return;
                                      }
                                      personNameController.clear();
                                      personEmailController.clear();
                                      personPasswordController.clear();
                                      personPhoneController.clear();
                                      Fluttertoast.showToast(msg: "Staff created successfully !!");
                                      KRoutes.pop(context);
                                    });
                                  }
                                }
                              }),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<void> createAdminDialog(
    BuildContext context,
    TextEditingController name,
    TextEditingController email,
    TextEditingController password,
    RestaurantModel restaurantModel, {
    bool update = false,
  }) async {
    final formKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, refreshState) {
            AdminViewModel? adminViewModel = context.watch<AdminViewModel>();
            return AlertDialog(
              scrollable: true,
              content: SizedBox(
                width: 300,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CustomText(text: "Create Admin"),
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomText(text: "Name"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: name,
                        suffixIcon: const Icon(Icons.shower_sharp),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomText(text: "Email"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: email,
                        suffixIcon: const Icon(Icons.email),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          if (!value.contains("@") || !value.contains(".")) {
                            return "Enter a valid Email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomText(text: "Password"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: password,
                        isPass: true,
                        keyboardtype: TextInputType.number,
                        suffixIcon: const Icon(Icons.visibility),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          if (value.length < 6) {
                            return "Password should not be less than 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      adminViewModel.loading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              buttonColor: primaryColor,
                              text: update == true ? "Update" : "create",
                              textColor: kWhite,
                              function: () async {
                                if (formKey.currentState!.validate()) {
                                  await adminViewModel
                                      .createAdmin(name.text, email.text, password.text, restaurantModel.name ?? "", restaurantModel.id ?? "")
                                      .then((value) {
                                    if (adminViewModel.modelError != null) {
                                      Fluttertoast.showToast(msg: adminViewModel.modelError!.errorResponse.toString());
                                      return;
                                    }
                                    KRoutes.pop(context);
                                    Fluttertoast.showToast(msg: "Admin created Successfully");
                                  });
                                }
                              }),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void createCategoryDialog(BuildContext context, TextEditingController categoryController, String restaurantId) {
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, refreshState) {
            MenuCategoryViewModel menuCategoryViewModel = context.watch<MenuCategoryViewModel>();
            return AlertDialog(
              scrollable: true,
              content: SizedBox(
                width: 300,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CustomText(text: "Create Category"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: categoryController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Fill this field";
                          }
                          return null;
                        },
                        suffixIcon: const Icon(Icons.shower_sharp),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      menuCategoryViewModel.loading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              buttonColor: primaryColor,
                              text: "create",
                              textColor: kWhite,
                              function: () async {
                                if (!formKey.currentState!.validate()) {
                                  Fluttertoast.showToast(msg: "Field can't be empty");
                                } else {
                                  await menuCategoryViewModel.createMenuCategory(categoryController.text, restaurantId).then((value) {
                                    if (menuCategoryViewModel.modelError != null) {
                                      Fluttertoast.showToast(msg: menuCategoryViewModel.modelError!.errorResponse.toString());
                                      menuCategoryViewModel.setModelError(null);
                                    } else {
                                      KRoutes.pop(context);
                                      Fluttertoast.showToast(msg: "Category created successfully");
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
        });
  }

  void createMenuItemDialog(BuildContext context, TextEditingController categoryController, String restaurantId) {
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, refreshState) {
            MenuCategoryViewModel menuCategoryViewModel = context.watch<MenuCategoryViewModel>();
            return AlertDialog(
              scrollable: true,
              content: SizedBox(
                width: 300,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CustomText(text: "Create Category"),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: categoryController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Fill this field";
                          }
                          return null;
                        },
                        suffixIcon: const Icon(Icons.shower_sharp),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      menuCategoryViewModel.loading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              buttonColor: primaryColor,
                              text: "create",
                              textColor: kWhite,
                              function: () async {
                                if (!formKey.currentState!.validate()) {
                                  Fluttertoast.showToast(msg: "Field can't be empty");
                                } else {
                                  await menuCategoryViewModel.createMenuCategory(categoryController.text, restaurantId).then((value) {
                                    if (menuCategoryViewModel.modelError != null) {
                                      Fluttertoast.showToast(msg: menuCategoryViewModel.modelError!.errorResponse.toString());
                                      menuCategoryViewModel.setModelError(null);
                                    } else {
                                      KRoutes.pop(context);
                                      Fluttertoast.showToast(msg: "Category created successfully");
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
        });
  }
}
