import 'package:beamer/beamer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../../Utils/app_routes.dart';
import '../../View Model/Resturants View Model/resturants_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController restaurantsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
            title: "Select restaurants",
            appBar: AppBar(),
            widgets: const [],
            appBarHeight: 50),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showCustomDialog(context);
            },
            label: const CustomText(
              text: "Create restaurants",
              color: kWhite,
            )),
        body: Center(
            child: StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child("restaurants")
                    .onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent?> snapshot) {
                  // return Container();
                  return restaurantsView(snapshot);
                })));
  }

  Widget restaurantsView(AsyncSnapshot<DatabaseEvent?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [CustomText(text: "No restaurants added Yet !!")],
      );
    }

    Map restaurantsObject = snapshot.data!.snapshot.value as Map;
    List restaurantskeysList = restaurantsObject.keys.toList();
    return Center(
      child: SingleChildScrollView(
        child: Wrap(
          children: restaurantskeysList.map((e) {
            Map restaurants = restaurantsObject[e];
            restaurants["key"] = e;
            final ref =
                StorageService.storage.ref().child(restaurants["imagePath"]);
            return GestureDetector(
              onTap: () {
                Beamer.of(context)
                    .beamToNamed("/restaurants-details/${restaurants["key"]}");
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: ref.getDownloadURL(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CircleAvatar(
                            radius: 100,
                            backgroundColor: kWhite,
                            foregroundImage: NetworkImage(snapshot.data!),
                          );
                        }
                        return const CircleAvatar(
                            radius: 100,
                            child: CircularProgressIndicator.adaptive());
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(restaurants["restaurantsName"].toString())
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void showCustomDialog(BuildContext context) {
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
                                foregroundImage: AssetImage(
                                    "assets/defaultresturantImage.png"),
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
                                final fileExtension =
                                    image!.files.single.extension;
                                await restaurantsViewModel
                                    .createrestaurants(
                                        restaurantsController.text,
                                        fileExtension!,
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
                            })
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  void dispose() {
    restaurantsController.dispose();
    super.dispose();
  }
}
