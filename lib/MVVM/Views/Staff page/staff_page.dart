import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/RestaurantsModel/restaurants_model.dart';
import 'package:restomation/MVVM/Models/Staff%20Model/staff_model.dart';
import 'package:restomation/MVVM/Repo/Staff%20Service/staff_service.dart';
import 'package:restomation/Provider/selected_restaurant_provider.dart';
import 'package:restomation/Utils/Helper%20Functions/essential_functions.dart';
import 'package:restomation/Widgets/custom_loader.dart';

import '../../../Utils/contants.dart';
import '../../../Widgets/custom_app_bar.dart';
import '../../../Widgets/custom_search.dart';
import '../../../Widgets/custom_text.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({
    super.key,
  });

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final TextEditingController personNameController = TextEditingController();
  final TextEditingController personPhoneController = TextEditingController();
  final TextEditingController personEmailController = TextEditingController();
  final TextEditingController personPasswordController = TextEditingController();
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    RestaurantModel? restaurantModel = context.read<SelectedRestaurantProvider>().restaurantModel;

    return Scaffold(
      appBar: BaseAppBar(
        title: restaurantModel?.name ?? "No name",
        appBar: AppBar(),
        widgets: const [],
        appBarHeight: 50,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            EssentialFunctions().createStaffDialog(
              context,
              restaurantModel!,
              personNameController,
              personPhoneController,
              personEmailController,
              personPasswordController,
            );
          },
          label: const CustomText(
            text: "Create Staff",
            color: Colors.white,
          )),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "Staff :",
                    fontsize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomSearch(
                    controller: controller,
                    searchText: "Search staff",
                    function: () {
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: StreamBuilder(
                        stream: StaffService().getStaff(restaurantModel?.id ?? " "),
                        builder: (context, AsyncSnapshot<List<StaffModel>> snapshot) {
                          return staffView(
                            snapshot,
                            restaurantModel!,
                          );
                        }),
                  ),
                ],
              ))),
    );
  }

  Widget staffView(
    AsyncSnapshot<List<StaffModel>> snapshot,
    RestaurantModel restaurantModel,
  ) {
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
          children: const [CustomText(text: "No staff added Yet !!")],
        ),
      );
    }
    List<StaffModel> allStaff = snapshot.data!;
    final suggestions = allStaff.where((element) {
      final categoryTitle = element.name!.toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    allStaff = suggestions;
    return Column(
      children: allStaff.map((e) {
        return Row(
          children: [
            Expanded(
              child: ListTile(
                title: CustomText(
                  text: e.email ?? "",
                  fontsize: 15,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: CustomText(text: e.role ?? ""),
              ),
            ),
            Row(
              children: [
                IconButton(
                  color: primaryColor,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  onPressed: () {
                    personNameController.text = e.name ?? "";
                    personPhoneController.text = e.phoneNo ?? "";
                    personEmailController.text = e.email ?? "";
                    EssentialFunctions().createStaffDialog(
                      context,
                      restaurantModel,
                      personNameController,
                      personPhoneController,
                      personEmailController,
                      personPasswordController,
                      update: true,
                    );
                  },
                ),
                IconButton(
                  color: Colors.red,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () async {},
                ),
              ],
            )
          ],
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    personNameController.dispose();
    personPhoneController.dispose();
    personEmailController.dispose();
    personPasswordController.dispose();
    controller.dispose();
    super.dispose();
  }
}
