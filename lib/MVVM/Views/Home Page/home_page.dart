import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/MVVM/View%20Model/Resturants%20View%20Model/resturants_view_model.dart';
import 'package:restomation/MVVM/Views/Resturant%20Details/resturant_details.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../../Utils/app_routes.dart';

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
    if (resturantViewModel.listResult!.prefixes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              "assets/emptyList.json",
              width: 200,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("No resturants yet !!"),
          ],
        ),
      );
    }
    return Center(
      child: Wrap(
        children: resturantViewModel.listResult!.prefixes.map((e) {
          final ref =
              StorageService.storage.ref().child('${e.fullPath}/logo/logo.png');
          return GestureDetector(
            onTap: () {
              KRoutes.push(
                  context,
                  ResturantDetailPage(
                    resturantName: e.fullPath,
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  Text(e.fullPath)
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
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
                              final fileBytes = image!.files.single.bytes;
                              final fileExtension =
                                  image!.files.single.extension;
                              await resturantViewModel
                                  .createResturant(resturantController.text,
                                      fileExtension!, fileBytes!)
                                  .then((value) {
                                if (resturantViewModel.modelError == null) {
                                  KRoutes.pop(context);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Unable to create resturant");
                                  resturantViewModel.setModelError(null);
                                }
                              });
                            })
                  ],
                ),
              ),
            );
          });
        });
  }
}
