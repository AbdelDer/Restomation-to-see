import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_search.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../../Widgets/custom_button.dart';

class TablesPage extends StatefulWidget {
  final String resturantKey;
  const TablesPage({super.key, required this.resturantKey});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final TextEditingController tableController = TextEditingController();
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
            text: "Create table",
            color: Colors.white,
          )),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: "All Tables :",
              fontsize: 35,
              fontWeight: FontWeight.bold,
            ),
            const CustomSearch(),
            Expanded(
              child: FirebaseAnimatedList(
                query: DatabaseService.getResturantsTables(widget.resturantKey),
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  Map table = snapshot.value as Map;
                  table["key"] = snapshot.key;

                  return Slidable(
                    endActionPane: _actionPane(table),
                    child: ListTile(
                      title: CustomText(
                        text: table["tableName"],
                        fontsize: 20,
                      ),
                      trailing: QrImage(
                        data: '${table["tableName"]}',
                        version: QrVersions.auto,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCustomDialog(BuildContext context,
      {bool update = false, Map? table}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomText(text: "Create Table"),
                  const SizedBox(
                    height: 10,
                  ),
                  FormTextField(
                    controller: tableController,
                    suffixIcon: const Icon(Icons.shower_sharp),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                      buttonColor: primaryColor,
                      text: update ? "Update" : "Create",
                      textColor: kWhite,
                      function: () async {
                        if (update) {
                          await DatabaseService.updateTable(widget.resturantKey,
                                  table!["key"], tableController.text)
                              .then((value) => KRoutes.pop(context));
                        } else {
                          await DatabaseService.createTable(
                                  widget.resturantKey, tableController.text)
                              .then((value) => KRoutes.pop(context));
                        }
                      })
                ],
              ),
            ),
          );
        });
  }

  ActionPane _actionPane(
    Map table,
  ) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          onPressed: (context) {
            tableController.text = table["tableName"];

            showCustomDialog(context, update: true, table: table);
          },
          backgroundColor: const Color(0xFF21B7CA),
          foregroundColor: Colors.white,
          icon: Icons.share,
          label: 'Edit',
        ),
        SlidableAction(
          onPressed: (context) {
            DatabaseService.db
                .ref()
                .child("resturants")
                .child(widget.resturantKey)
                .child("tables")
                .child(table["key"])
                .remove();
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ],
    );
  }

  @override
  void dispose() {
    tableController.dispose();
    super.dispose();
  }
}
