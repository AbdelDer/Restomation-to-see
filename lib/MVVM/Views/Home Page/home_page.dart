import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/MVVM/View%20Model/Resturants%20View%20Model/resturants_view_model.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../../Utils/app_routes.dart';
import '../Resturant Details/resturant_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController resturantController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ResturantViewModel resturantViewModel = context.watch<ResturantViewModel>();
    return Scaffold(
        appBar: BaseAppBar(
            title: "Select Resturant",
            appBar: AppBar(),
            widgets: const [],
            appBarHeight: 50),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showCustomDialog(context);
            },
            label: const CustomText(
              text: "Create resturant",
              color: kWhite,
            )),
        body: resturantsView(resturantViewModel));
  }

  Widget resturantsView(ResturantViewModel resturantViewModel) {
    if (resturantViewModel.loading) {
      return const Center(child: CustomLoader());
    }
    if (resturantViewModel.modelError != null) {
      return Center(
        child: Text(resturantViewModel.modelError!.errorResponse.toString()),
      );
    }
    return Center(
        child: FirebaseAnimatedList(
      query: DatabaseService.getAllresturants(),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        Map resturant = snapshot.value as Map;
        resturant["key"] = snapshot.key;
        final ref = StorageService.storage.ref().child(resturant["imagePath"]);
        return GestureDetector(
          onTap: () {
            KRoutes.push(
                context,
                ResturantDetailPage(
                  resturantName: resturant["resturantName"],
                  resturantKey: resturant["key"],
                ));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
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
                Text(resturant["resturantName"])
              ],
            ),
          ),
        );
      },
    ));
  }

  void showCustomDialog(BuildContext context) {
    FilePickerResult? image;
    showDialog(
        context: context,
        builder: (context) {
          ResturantViewModel resturantViewModel =
              context.watch<ResturantViewModel>();
          return StatefulBuilder(builder: (context, refreshState) {
            return AlertDialog(
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                    "assets/defaultResturantImage.png"),
                              )),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: resturantController,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    resturantViewModel.loading
                        ? const CircularProgressIndicator.adaptive()
                        : CustomButton(
                            buttonColor: primaryColor,
                            text: "create",
                            textColor: kWhite,
                            function: () async {
                              if (resturantController.text.isEmpty ||
                                  image == null) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Make sure to upload a Resturant Logo and a Valid name");
                              } else {
                                final fileBytes = image!.files.single.bytes;
                                final fileExtension =
                                    image!.files.single.extension;
                                await resturantViewModel
                                    .createResturant(resturantController.text,
                                        fileExtension!, fileBytes!)
                                    .then((value) {
                                  resturantController.clear();
                                  if (resturantViewModel.modelError == null) {
                                    KRoutes.pop(context);
                                    Fluttertoast.showToast(
                                        msg: "resturant created");
                                    resturantViewModel.setModelError(null);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Unable to create resturant");
                                    resturantViewModel.setModelError(null);
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
    resturantController.dispose();
    super.dispose();
  }
}
