import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Staff%20page/staff_page.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: "Select a staff category :",
              fontsize: 35,
              fontWeight: FontWeight.bold,
            ),
            const CustomSearch(),
            Expanded(
              child: FirebaseAnimatedList(
                query: DatabaseService.getStaffCategories(widget.resturantKey),
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  Map staffCategory = snapshot.value as Map;
                  staffCategory["key"] = snapshot.key;

                  return ListTile(
                    title: CustomText(
                      text: staffCategory["staffCategoryName"].toString(),
                      fontsize: 20,
                    ),
                    onTap: () {
                      KRoutes.push(
                          context,
                          StaffPage(
                            resturantKey: widget.resturantKey,
                            staffCategoryKey: staffCategory["key"],
                            staffCategoryName:
                                staffCategory["staffCategoryName"],
                            resturantName: widget.resturantName,
                          ));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
                        await DatabaseService.createStaffCategory(
                                widget.resturantKey,
                                satffCategoryController.text)
                            .then((value) => KRoutes.pop(context));
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
    super.dispose();
  }
}
