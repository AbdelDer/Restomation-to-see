import 'package:beamer/beamer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_search.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../../Widgets/custom_alert.dart';
import '../../../Widgets/custom_button.dart';

class TablesPage extends StatefulWidget {
  final String resturantKey;
  final String resturantName;
  const TablesPage(
      {super.key, required this.resturantKey, required this.resturantName});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final TextEditingController tableController = TextEditingController();

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
            text: "Create table",
            color: Colors.white,
          )),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "All Tables :",
                    fontsize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomSearch(
                    controller: controller,
                    searchText: "Search Tables",
                    function: () {
                      setState(() {});
                    },
                  ),
                  StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child("resturants")
                          .child(widget.resturantKey)
                          .child("tables")
                          .onValue,
                      builder:
                          (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        return tableView(snapshot);
                      }),
                ],
              ))),
    );
  }

  Widget tableView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Expanded(child: CustomLoader());
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Expanded(
        child: Center(child: CustomText(text: "No Tables Added Yet !!")),
      );
    }
    Map allResturantsTables = snapshot.data!.snapshot.value as Map;
    List resturantsTables = allResturantsTables.keys.toList();
    final suggestions = allResturantsTables.keys.toList().where((element) {
      final categoryTitle =
          allResturantsTables[element]["tableName"].toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    resturantsTables = suggestions;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: resturantsTables.map((e) {
            Map table = allResturantsTables[e] as Map;
            table["key"] = e;

            return Slidable(
              endActionPane: _actionPane(table),
              child: InkWell(
                onTap: () {
                  Beamer.of(context).beamToNamed(
                      "/customer-table/${widget.resturantKey},${widget.resturantName},${table["tableName"]}");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: table["tableName"],
                      fontsize: 20,
                    ),
                    QrImage(
                      data:
                          'https://naqeeb9a.github.io/#/customer-table/${widget.resturantKey},${widget.resturantName},${table["tableName"]}',
                      version: QrVersions.auto,
                      size: 150,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
                        Alerts.customLoadingAlert(context);
                        if (update) {
                          await DatabaseService.updateTable(widget.resturantKey,
                                  table!["key"], tableController.text)
                              .then((value) {
                            KRoutes.pop(context);
                            return KRoutes.pop(context);
                          });
                        } else {
                          await DatabaseService.createTable(
                                  widget.resturantKey, tableController.text)
                              .then((value) {
                            KRoutes.pop(context);
                            return KRoutes.pop(context);
                          });
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
    controller.dispose();
    super.dispose();
  }
}
