import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/Customer%20Model/customer_model.dart';
import 'package:restomation/MVVM/View%20Model/Resturants%20View%20Model/resturants_view_model.dart';
import 'package:restomation/MVVM/View%20Model/Tables%20View%20Model/tables_view_model.dart';
import 'package:restomation/Provider/customer_provider.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../Repo/Storage Service/storage_service.dart';

class CustomerPage extends StatefulWidget {
  final String restaurantKey;
  final String tableKey;
  const CustomerPage({
    super.key,
    required this.restaurantKey,
    required this.tableKey,
  });

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    RestaurantsViewModel restaurantsViewModel =
        context.watch<RestaurantsViewModel>();
    TablesViewModel tablesViewModel = context.watch<TablesViewModel>();

    return Scaffold(
        backgroundColor: kWhite,
        appBar: BaseAppBar(
            title: "Restomation",
            appBar: AppBar(),
            widgets: const [],
            appBarHeight: 50),
        body: customerPageView(restaurantsViewModel, tablesViewModel));
  }

  Widget customerPageView(RestaurantsViewModel restaurantsViewModel,
      TablesViewModel tablesViewModel) {
    if ((restaurantsViewModel.restaurantModel == null &&
            restaurantsViewModel.loading == false) ||
        (tablesViewModel.loading == false &&
            tablesViewModel.tablesModel == null)) {
      Future.delayed(const Duration(milliseconds: 600), () {
        restaurantsViewModel.getSingleRestaurant(widget.restaurantKey);
        tablesViewModel.getSingleTable(widget.restaurantKey, widget.tableKey);
      });
      return const CustomLoader();
    }
    if (restaurantsViewModel.loading || tablesViewModel.loading) {
      return const CustomLoader();
    }
    if (restaurantsViewModel.modelError != null ||
        tablesViewModel.modelError != null) {
      return const Center(
        child: CustomText(
            text:
                "We were unable to setup the customer protal for you please contact the restaurant manager !!"),
      );
    }
    final ref = StorageService.storage
        .ref()
        .child(restaurantsViewModel.restaurantModel?.imagePath ?? "");
    String selectedValue = "yes";
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                CustomText(
                  text:
                      "Welcome to ${restaurantsViewModel.restaurantModel?.name}",
                  fontsize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: FutureBuilder(
                    future: ref.getDownloadURL(),
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
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
                ),
                const SizedBox(
                  height: 20,
                ),
                const CustomText(text: "Name :"),
                const SizedBox(
                  height: 20,
                ),
                FormTextField(
                  controller: nameController,
                  suffixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const CustomText(text: "Phone no :"),
                const SizedBox(
                  height: 20,
                ),
                FormTextField(
                  controller: phoneController,
                  maxLength: 10,
                  keyboardtype: TextInputType.number,
                  suffixIcon: const Icon(Icons.numbers),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    }
                    if (value.length < 10) {
                      return "Number cannot be less than 10 digits";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const Align(
                    alignment: Alignment.center,
                    child: CustomText(text: "Is your Table clean ?")),
                const SizedBox(
                  height: 20,
                ),
                StatefulBuilder(builder: (context, refreshState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        buttonColor:
                            selectedValue == "yes" ? primaryColor : kGrey,
                        text: "Yes",
                        textColor: kWhite,
                        function: () {
                          refreshState(() {
                            selectedValue = "yes";
                          });
                        },
                        width: 130,
                        height: 40,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      CustomButton(
                        buttonColor:
                            selectedValue == "no" ? primaryColor : kGrey,
                        text: "No",
                        textColor: kWhite,
                        function: () {
                          refreshState(() {
                            selectedValue = "no";
                          });
                        },
                        width: 130,
                        height: 40,
                      ),
                    ],
                  );
                }),
                const SizedBox(
                  height: 40,
                ),
                Align(
                  alignment: Alignment.center,
                  child: CustomButton(
                      buttonColor: primaryColor,
                      text: "Enter",
                      textColor: kWhite,
                      function: () {
                        if (formKey.currentState!.validate()) {
                          context.read<CustomerProvider>().setCustomer(
                              CustomerModel(
                                  name: nameController.text,
                                  phone: phoneController.text,
                                  isTableClean: selectedValue));
                          context.push("/customer-menu-page");
                        }
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
