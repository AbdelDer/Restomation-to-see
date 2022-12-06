import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../Repo/Storage Service/storage_service.dart';

class CustomerPage extends StatefulWidget {
  final String restaurantsKey;
  final String tableKey;
  final String restaurantsImageName;
  const CustomerPage(
      {super.key,
      required this.restaurantsKey,
      required this.tableKey,
      required this.restaurantsImageName});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ref = StorageService.storage
        .ref()
        .child("restaurantLogos/")
        .child(widget.restaurantsImageName);
    String selectedValue = "yes";
    return Scaffold(
      backgroundColor: kWhite,
      appBar: BaseAppBar(
          title: "Restomation",
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                CustomText(
                  text: "Welcome to ${widget.restaurantsKey}",
                  fontsize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: FutureBuilder(
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
                ),
                const SizedBox(
                  height: 20,
                ),
                const CustomText(text: "Name :"),
                const SizedBox(
                  height: 20,
                ),
                FormTextField(
                    controller: nameController,
                    suffixIcon: const Icon(Icons.email_outlined)),
                const SizedBox(
                  height: 20,
                ),
                const CustomText(text: "Phone no :"),
                const SizedBox(
                  height: 20,
                ),
                FormTextField(
                    controller: phoneController,
                    maxLength: 10,
                    keyboardtype: TextInputType.number,
                    suffixIcon: const Icon(Icons.numbers)),
                const SizedBox(
                  height: 20,
                ),
                const Align(
                    alignment: Alignment.center,
                    child: CustomText(text: "Is your Table clean ?")),
                const SizedBox(
                  height: 20,
                ),
                StatefulBuilder(builder: (context, refreshState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        buttonColor:
                            selectedValue == "yes" ? primaryColor : kGrey,
                        text: "Yes",
                        textColor: kWhite,
                        function: () {
                          refreshState(() {
                            selectedValue = "yes";
                          });
                        },
                        width: 130,
                        height: 40,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      CustomButton(
                        buttonColor:
                            selectedValue == "no" ? primaryColor : kGrey,
                        text: "No",
                        textColor: kWhite,
                        function: () {
                          refreshState(() {
                            selectedValue = "no";
                          });
                        },
                        width: 130,
                        height: 40,
                      ),
                    ],
                  );
                }),
                const SizedBox(
                  height: 40,
                ),
                Align(
                  alignment: Alignment.center,
                  child: CustomButton(
                      buttonColor: primaryColor,
                      text: "Enter",
                      textColor: kWhite,
                      function: () {
                        Beamer.of(context).beamToNamed(
                            "/restaurants-menu-category/${widget.restaurantsKey},${widget.tableKey},${nameController.text},${phoneController.text},$selectedValue");
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
