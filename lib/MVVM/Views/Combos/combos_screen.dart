import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';

import '../../../Widgets/custom_loader.dart';
import '../../../Widgets/custom_search.dart';
import '../../../Widgets/custom_text.dart';

class CombosScreen extends StatefulWidget {
  final String restaurantsKey;
  const CombosScreen({super.key, required this.restaurantsKey});

  @override
  State<CombosScreen> createState() => _CombosScreenState();
}

class _CombosScreenState extends State<CombosScreen> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: widget.restaurantsKey,
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "All Combos :",
                    fontsize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomSearch(
                    controller: controller,
                    searchText: "Search Combos",
                    function: () {
                      setState(() {});
                    },
                  ),
                  StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child("restaurants")
                          .child(widget.restaurantsKey)
                          .child("combos")
                          .onValue,
                      builder:
                          (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        return combosView(snapshot);
                      }),
                ],
              ))),
    );
  }

  Widget combosView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Expanded(child: CustomLoader());
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Expanded(
        child: Center(child: CustomText(text: "No Combos created Yet !!")),
      );
    }
    Map allrestaurantsCombos = snapshot.data!.snapshot.value as Map;
    List restaurantsTables = allrestaurantsCombos.keys.toList();
    final suggestions = allrestaurantsCombos.keys.toList().where((element) {
      final categoryTitle =
          allrestaurantsCombos[element]["combos"].toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    restaurantsTables = suggestions;
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        return Container();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
