import 'package:beamer/beamer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_loader.dart';

import '../../../Widgets/custom_alert.dart';
import '../../../Widgets/custom_search.dart';
import '../../../Widgets/custom_text.dart';
import '../../../Widgets/custom_text_field.dart';

class StaffCategoryPage extends StatefulWidget {
  final String resturantKey;
  final String resturantName;
  const StaffCategoryPage(
      {super.key, required this.resturantKey, required this.resturantName});

  @override
  State<StaffCategoryPage> createState() => _StaffCategoryPageState();
}

class _StaffCategoryPageState extends State<StaffCategoryPage> {
  final TextEditingController satffCategoryController = TextEditingController();
  final TextEditingController controller = TextEditingController();

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
          label: const CustomText(
            text: "Create Staff Category",
            color: kWhite,
          )),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "Select a staff category :",
                    fontsize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomSearch(
                    controller: controller,
                    searchText: "Search Category",
                    function: () {
                      setState(() {});
                    },
                  ),
                  StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child("resturants")
                          .child(widget.resturantKey)
                          .child("staff")
                          .onValue,
                      builder:
                          (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        return categoriesView(snapshot);
                      }),
                ],
              ))),
    );
  }

  Widget categoriesView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Expanded(child: CustomLoader());
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Expanded(
          child: Center(child: Text("No Staff categories yet !!")));
    }
    Map allStaffCategories = snapshot.data!.snapshot.value as Map;
    List categoriesStaffList = allStaffCategories.keys.toList();
    final suggestions = allStaffCategories.keys.toList().where((element) {
      final categoryTitle = allStaffCategories[element]["staffCategoryName"]
          .toString()
          .toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    categoriesStaffList = suggestions;
    return Column(
      children: categoriesStaffList.map((e) {
        Map staffCategory = allStaffCategories[e] as Map;
        staffCategory["key"] = e;

        return ListTile(
          title: CustomText(
            text: staffCategory["staffCategoryName"].toString(),
            fontsize: 20,
          ),
          onTap: () {
            Beamer.of(context).beamToNamed(
                "/resturant-staff-category/staff/${widget.resturantName},${widget.resturantKey},${staffCategory["staffCategoryName"]},${staffCategory["key"]}");
          },
        );
      }).toList(),
    );
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomText(text: "Create Staff Category"),
                  const SizedBox(
                    height: 10,
                  ),
                  FormTextField(
                    controller: satffCategoryController,
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
                        await DatabaseService.createStaffCategory(
                                widget.resturantKey,
                                satffCategoryController.text)
                            .then((value) {
                          KRoutes.pop(context);
                          return KRoutes.pop(context);
                        });
                      })
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    satffCategoryController.dispose();
    controller.dispose();
    super.dispose();
  }
}
