import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restomation/MVVM/Models/Tables%20Model/tables_model.dart';
import 'package:restomation/Utils/Helper%20Functions/essential_functions.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_search.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../Models/RestaurantsModel/restaurants_model.dart';
import '../../Repo/Tables Service/tables_service.dart';
import '../../View Model/Tables View Model/tables_view_model.dart';

class TablesPage extends StatefulWidget {
  final RestaurantModel restaurantModel;
  const TablesPage({
    super.key,
    required this.restaurantModel,
  });

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final TextEditingController tableController = TextEditingController();

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TablesViewModel tablesViewModel = context.watch<TablesViewModel>();
    return Scaffold(
      appBar: BaseAppBar(
        title: widget.restaurantModel.name ?? "",
        appBar: AppBar(),
        widgets: const [],
        appBarHeight: 50,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            EssentialFunctions().createUpdateTable(context,
                widget.restaurantModel, tableController, tablesViewModel);
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
                      stream: TablesService()
                          .getTables(widget.restaurantModel.id ?? " "),
                      builder:
                          (context, AsyncSnapshot<List<TablesModel>> snapshot) {
                        return tableView(
                            snapshot, widget.restaurantModel, tablesViewModel);
                      }),
                ],
              ))),
    );
  }

  Widget tableView(AsyncSnapshot<List<TablesModel>> snapshot,
      RestaurantModel? restaurantModel, TablesViewModel tablesViewModel) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Expanded(child: CustomLoader());
    }
    if (snapshot.hasError) {
      return const Center(
        child: CustomText(text: "Error"),
      );
    }
    if (snapshot.data!.isEmpty) {
      return const Expanded(
        child: Center(child: CustomText(text: "No Tables Added Yet !!")),
      );
    }

    List<TablesModel> restaurantsList = snapshot.data!;
    final suggestions = restaurantsList.where((element) {
      final categoryTitle = element.name.toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    restaurantsList = suggestions;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: restaurantsList.map((e) {
            e.id = e.id;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        context.push(
                          "/customer-page/${restaurantModel?.id},${e.id},c93f245aa6c85b1b3bf5e2163c6b1405.jpg",
                        );
                      },
                      child: CustomText(
                        text: e.name ?? "",
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
                                data: e.qrLink ?? "",
                                version: QrVersions.auto,
                              ),
                            ),
                          ),
                        );
                      },
                      child: QrImage(
                        data: e.qrLink ?? "",
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
                        tableController.text = e.name ?? "";

                        EssentialFunctions().createUpdateTable(context,
                            restaurantModel, tableController, tablesViewModel,
                            table: e, update: true);
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
                        await FirebaseFirestore.instance
                            .collection("/restaurants")
                            .doc(restaurantModel?.id ?? "")
                            .collection("tables")
                            .doc(e.id)
                            .delete();
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

  @override
  void dispose() {
    tableController.dispose();
    controller.dispose();
    super.dispose();
  }
}
