import 'package:beamer/beamer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
  final String restaurantsKey;
  final String restaurantsImageName;
  const TablesPage({
    super.key,
    required this.restaurantsKey,
    required this.restaurantsImageName,
  });

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
          onPressed: () async {
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
                          .child("tables")
                          .child(widget.restaurantsKey)
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

    Map allrestaurantsTables = snapshot.data!.snapshot.value as Map;
    List restaurantsTables = allrestaurantsTables.keys.toList();
    final suggestions = allrestaurantsTables.keys.toList().where((element) {
      final categoryTitle =
          allrestaurantsTables[element]["tableName"].toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    restaurantsTables = suggestions;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: restaurantsTables.map((e) {
            Map table = allrestaurantsTables[e] as Map;
            table["key"] = e;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Beamer.of(context).beamToNamed(
                            '/customer-table/${widget.restaurantsKey},${table["table_name"]},${widget.restaurantsImageName}');
                      },
                      child: CustomText(
                        text: table["table_name"],
                        fontsize: 20,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: QrImage(
                                data: '${table["qrLink"]}',
                                version: QrVersions.auto,
                              ),
                            ),
                          ),
                        );
                      },
                      child: QrImage(
                        data: '${table["qrLink"]}',
                        version: QrVersions.auto,
                        size: 150,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      color: primaryColor,
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      onPressed: () {
                        tableController.text = table["table_name"];

                        showCustomDialog(context, table: table, update: true);
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
                      onPressed: () {
                        DatabaseService.db
                            .ref()
                            .child("tables")
                            .child(widget.restaurantsKey)
                            .child(table["key"])
                            .remove();
                      },
                    ),
                  ],
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void showCustomDialog(BuildContext context,
      {bool update = false, Map? table}) {
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(text: "Create Table"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: tableController,
                      suffixIcon: const Icon(Icons.table_bar),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Fill this field";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        buttonColor: primaryColor,
                        text: update ? "Update" : "Create",
                        textColor: kWhite,
                        function: () async {
                          if (formKey.currentState!.validate()) {
                            Alerts.customLoadingAlert(context);
                            if (update) {
                              await DatabaseService.updateTable(
                                      widget.restaurantsKey,
                                      table!["key"],
                                      tableController.text,
                                      'https://naqeeb9a.github.io/#/customer-table/${widget.restaurantsKey},${tableController.text},${widget.restaurantsImageName}')
                                  .then((value) {
                                KRoutes.pop(context);
                                return KRoutes.pop(context);
                              });
                            } else {
                              await DatabaseService.createTable(
                                      widget.restaurantsKey,
                                      tableController.text,
                                      'https://naqeeb9a.github.io/#/customer-table/${widget.restaurantsKey},${tableController.text},${widget.restaurantsImageName}')
                                  .then((value) {
                                KRoutes.pop(context);
                                return KRoutes.pop(context);
                              });
                            }
                          }
                        })
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    tableController.dispose();
    controller.dispose();
    super.dispose();
  }
}
