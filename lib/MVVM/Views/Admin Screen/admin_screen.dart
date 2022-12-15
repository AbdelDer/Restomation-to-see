import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/RestaurantsModel/restaurants_model.dart';
import 'package:restomation/MVVM/Repo/Admin%20Service/admin_service.dart';
import 'package:restomation/Utils/Helper%20Functions/essential_functions.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';

import '../../../Provider/selected_restaurant_provider.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_search.dart';
import '../../../Widgets/custom_text.dart';
import '../../Models/Admin Model/admin_model.dart';

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
    RestaurantModel? restaurantModel =
        context.read<SelectedRestaurantProvider>().restaurantModel;
    return Scaffold(
      appBar: BaseAppBar(
          title: restaurantModel?.name ?? "No name",
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            EssentialFunctions().createAdminDialog(
                context, name, email, password, restaurantModel!);
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
                        stream:
                            AdminService().getAdmin(restaurantModel?.id ?? ""),
                        builder: (context,
                            AsyncSnapshot<List<AdminModel>> snapshot) {
                          return adminView(snapshot, restaurantModel!);
                        }),
                  ),
                ],
              ))),
    );
  }

  Widget adminView(AsyncSnapshot<List<AdminModel>> snapshot,
      RestaurantModel restaurantModel) {
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
    if (snapshot.data!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CustomText(text: "No admins added Yet !!")],
        ),
      );
    }
    List<AdminModel> allAdmins = snapshot.data!;
    final suggestions = allAdmins.where((element) {
      final categoryTitle = element.email.toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    allAdmins = suggestions;
    return Column(
      children: allAdmins.map((e) {
        return Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                  e.email ?? "",
                ),
                subtitle: Text(e.name ?? ""),
                trailing: const Icon(Icons.person_outline),
              ),
            ),
            IconButton(
              color: primaryColor,
              icon: const Icon(
                Icons.edit_outlined,
              ),
              onPressed: () async {
                name.text = e.name ?? "";
                email.text = e.email ?? "";
                await EssentialFunctions()
                    .createAdminDialog(
                        context, name, email, password, restaurantModel,
                        update: true)
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
              onPressed: () async {},
            ),
          ],
        );
      }).toList(),
    );
  }
}
