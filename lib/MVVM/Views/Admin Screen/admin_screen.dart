import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_alert.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';

import '../../../Utils/contants.dart';
import '../../../Widgets/custom_button.dart';
import '../../../Widgets/custom_search.dart';
import '../../../Widgets/custom_text.dart';
import '../../../Widgets/custom_text_field.dart';

class AdminScreen extends StatefulWidget {
  final String restaurantsKey;
  const AdminScreen({super.key, required this.restaurantsKey});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: widget.restaurantsKey,
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showCustomDialog(context);
          },
          label: const CustomText(
            text: "Create Admin",
            color: Colors.white,
          )),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "Admins :",
                    fontsize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomSearch(
                    controller: controller,
                    searchText: "Search Admins",
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
                            .child("admins")
                            .onValue,
                        builder:
                            (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                          return adminView(snapshot);
                        }),
                  ),
                ],
              ))),
    );
  }

  Widget adminView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CustomText(text: "Something went wrong")],
        ),
      );
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CustomText(text: "No admins added Yet !!")],
        ),
      );
    }
    Map allAdmins = snapshot.data!.snapshot.value as Map;
    List adminsList = allAdmins.keys.toList();
    final suggestions = allAdmins.keys.toList().where((element) {
      final categoryTitle =
          allAdmins[element]["email"].toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    adminsList = suggestions;
    return Column(
      children: adminsList.map((e) {
        Map person = allAdmins[e] as Map;
        person["key"] = e;
        return ListTile(
          title: Text(
            person["email"],
          ),
          trailing: const Icon(Icons.person_outline),
        );
      }).toList(),
    );
  }

  void showCustomDialog(BuildContext context) {
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
                      suffixIcon: const Icon(Icons.shower_sharp),
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
                      keyboardtype: TextInputType.number,
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
                          await DatabaseService.createSubAdminRestaurant(
                                  widget.restaurantsKey,
                                  name.text,
                                  email.text,
                                  password.text,
                                  "/restaurants-details/${widget.restaurantsKey}")
                              .then((value) {
                            KRoutes.pop(context);
                            KRoutes.pop(context);
                            return Fluttertoast.showToast(
                                msg: "Admin Created Successfully");
                          });
                        }),
                  ],
                ),
              ),
            );
          });
        });
  }
}
