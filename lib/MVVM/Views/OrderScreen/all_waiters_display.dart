import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_alert.dart';
import 'package:restomation/Widgets/custom_loader.dart';

import '../../../Utils/contants.dart';
import '../../../Widgets/custom_text.dart';

class AllWaiterDisplay extends StatelessWidget {
  final String restaurantKey;
  final String tableKey;
  const AllWaiterDisplay(
      {super.key, required this.restaurantKey, required this.tableKey});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const CustomText(
        text: "All Waiters",
        fontWeight: FontWeight.bold,
        fontsize: 20,
      ),
      content: SizedBox(
        height: 500,
        width: 500,
        child: StreamBuilder(
            stream: DatabaseService.db
                .ref()
                .child("staff")
                .orderByChild("assigned_restaurant")
                .equalTo(restaurantKey)
                .onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
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
                    children: const [
                      CustomText(text: "No waiter added Yet !!")
                    ],
                  ),
                );
              }
              Map allStaff = snapshot.data!.snapshot.value as Map;
              List staffList = allStaff.keys.toList();
              final suggestions = staffList.where((element) {
                final categoryTitle =
                    allStaff[element]["role"].toString().toLowerCase();
                const input = "waiter";
                return categoryTitle == input;
              }).toList();
              staffList = suggestions;
              return ListView.builder(
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  String personKey = staffList[index];
                  Map person = allStaff[personKey] as Map;
                  person["key"] = personKey;
                  final ref =
                      StorageService.storage.ref().child(person["image"]);
                  return ListTile(
                    onTap: () {
                      Alerts.customLoadingAlert(context);
                      DatabaseService.db
                          .ref()
                          .child("orders")
                          .child(restaurantKey)
                          .child(tableKey)
                          .update({"waiter": person["name"]});
                      KRoutes.pop(context);
                      KRoutes.pop(context);
                    },
                    leading: FutureBuilder(
                        future: ref.getDownloadURL(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CircleAvatar(
                              backgroundColor: kWhite,
                              foregroundImage: NetworkImage(snapshot.data!),
                            );
                          }
                          return const CircleAvatar(
                            backgroundColor: kWhite,
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }),
                    title: Text(
                      person["name"],
                    ),
                    subtitle: Text(person["role"]),
                    trailing: const Icon(Icons.person_outline),
                  );
                },
              );
            }),
      ),
    );
  }
}
