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
  const AdminScreen({
    super.key,
  });

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
          title: "", appBar: AppBar(), widgets: const [], appBarHeight: 50),
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
                            .child("admins")
                            .orderByChild("assigned_restaurant")
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
        return Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                  person["email"],
                ),
                subtitle: Text(person["password"]),
                trailing: const Icon(Icons.person_outline),
              ),
            ),
            IconButton(
              color: primaryColor,
              icon: const Icon(
                Icons.edit_outlined,
              ),
              onPressed: () async {
                name.text = person["name"];
                email.text = person["email"];
                password.text = person["password"];
                await showCustomDialog(context, person: person, update: true)
                    .then((value) {
                  name.clear();
                  email.clear();
                  password.clear();
                });
              },
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              color: Colors.red,
              icon: const Icon(
                Icons.delete_outline,
              ),
              onPressed: () async {
                await DatabaseService.db
                    .ref()
                    .child("admins")
                    .child(person["key"])
                    .remove();
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  Future<void> showCustomDialog(BuildContext context,
      {bool update = false, Map? person}) async {
    final formKey = GlobalKey<FormState>();
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, refreshState) {
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
                      CustomButton(
                          buttonColor: primaryColor,
                          text: update == true ? "Update" : "create",
                          textColor: kWhite,
                          function: () async {
                            if (formKey.currentState!.validate()) {
                              Alerts.customLoadingAlert(context);
                              await DatabaseService.createSubAdminRestaurant(
                                      ",", name.text, email.text, password.text,
                                      update: update, personKey: person?["key"])
                                  .then((value) {
                                KRoutes.pop(context);
                                KRoutes.pop(context);
                                return Fluttertoast.showToast(
                                    msg: update == true
                                        ? "Admin Updated Successfully"
                                        : "Admin Created Successfully");
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
}
