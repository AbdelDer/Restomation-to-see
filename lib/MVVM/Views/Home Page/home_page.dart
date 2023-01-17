import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restomation/MVVM/Repo/Restaurant%20Service/restaurant_service.dart';
import 'package:restomation/Utils/Helper%20Functions/essential_functions.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../Models/RestaurantsModel/restaurants_model.dart';
import '../../Repo/Storage Service/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController restaurantsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
            title: "Select restaurants",
            appBar: AppBar(),
            widgets: const [],
            appBarHeight: 50),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              EssentialFunctions()
                  .createRestaurantDialogue(context, restaurantsController);
            },
            label: const CustomText(
              text: "Create restaurants",
              color: kWhite,
            )),
        body: Center(
            child: StreamBuilder(
                stream: RestaurantService().getRestaurants(),
                builder:
                    (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
                  return restaurantsView(snapshot);
                })));
  }

  Widget restaurantsView(AsyncSnapshot<List<RestaurantModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.hasError) {
      return const Center(
        child: CustomText(text: "Error"),
      );
    }
    if (snapshot.data!.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [CustomText(text: "No restaurants added Yet !!")],
      );
    }
    List<RestaurantModel> restaurantsList = snapshot.data!;
    return Center(
      child: SingleChildScrollView(
        child: Wrap(
          children: restaurantsList.map((e) {
            final ref = StorageService.storage.ref().child(e.imagePath!);
            return GestureDetector(
              onTap: () {
                context.push("/restaurant-details",
                    extra: RestaurantModel.toJson(e));
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: ref.getDownloadURL(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CircleAvatar(
                            radius: 100,
                            backgroundColor: kWhite,
                            foregroundImage: NetworkImage(snapshot.data!),
                          );
                        }
                        return const CircleAvatar(
                            radius: 100,
                            child: CircularProgressIndicator.adaptive());
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(e.name!)
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    restaurantsController.dispose();
    super.dispose();
  }
}
