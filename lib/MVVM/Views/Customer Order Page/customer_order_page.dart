import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Customer%20Service/customer_service.dart';
import 'package:restomation/MVVM/Views/Customer%20Order%20Page/customer_order_item_display.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Widgets/custom_loader.dart';
import '../../Models/Customer Model/customer_order_model.dart';
import '../../View Model/Resturants View Model/resturants_view_model.dart';
import '../../View Model/Tables View Model/tables_view_model.dart';

class CustomerOrderPage extends StatelessWidget {
  final String restaurantKey;
  final String tableKey;

  const CustomerOrderPage({
    super.key,
    required this.restaurantKey,
    required this.tableKey,
  });

  @override
  Widget build(BuildContext context) {
    RestaurantsViewModel restaurantsViewModel =
        context.watch<RestaurantsViewModel>();
    TablesViewModel tablesViewModel = context.watch<TablesViewModel>();
    return Scaffold(
        appBar: BaseAppBar(
            title: "Table Order",
            appBar: AppBar(),
            widgets: const [],
            appBarHeight: 50),
        body: customerOrderView(restaurantsViewModel, tablesViewModel));
  }

  Widget customerOrderView(RestaurantsViewModel restaurantsViewModel,
      TablesViewModel tablesViewModel) {
    if ((restaurantsViewModel.restaurantModel == null &&
            restaurantsViewModel.loading == false) ||
        (tablesViewModel.loading == false &&
            tablesViewModel.tablesModel == null)) {
      Future.delayed(const Duration(milliseconds: 600), () {
        restaurantsViewModel.getSingleRestaurant(restaurantKey);
        tablesViewModel.getSingleTable(restaurantKey, tableKey);
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
    return StreamBuilder(
      stream: CustomerService().getCustomerOrder(restaurantKey, tableKey),
      builder: (context, AsyncSnapshot<List<CustomerOrderModel>> snapshot) {
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
            children: const [CustomText(text: "No Order placed Yet !!")],
          );
        }
        List<CustomerOrderModel> order = snapshot.data!;
        return Scaffold(
          floatingActionButton: (order[0].waiter != "none")
              ? FloatingActionButton.extended(
                  onPressed: () async {},
                  label: Row(
                    children: const [
                      Icon(Icons.notifications),
                      SizedBox(
                        width: 10,
                      ),
                      CustomText(
                        text: "Call waiter",
                        color: kWhite,
                      ),
                    ],
                  ))
              : null,
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kGrey.shade300),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Customer name :",
                            fontWeight: FontWeight.bold,
                            fontsize: 20,
                          ),
                          CustomText(
                            text: order[0].name ?? "none",
                            fontsize: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Customer phone :",
                            fontWeight: FontWeight.bold,
                            fontsize: 20,
                          ),
                          CustomText(
                            text: order[0].phone ?? "none",
                            fontsize: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Assigned Waiter :",
                            fontWeight: FontWeight.bold,
                            fontsize: 20,
                          ),
                          CustomText(
                            text: order[0].waiter ?? "none",
                            color: order[0].waiter == "none"
                                ? Colors.red
                                : Colors.green,
                            fontsize: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Order Status :",
                            fontWeight: FontWeight.bold,
                            fontsize: 20,
                          ),
                          CustomText(
                            text: order[0].orderStatus ?? "none",
                            color:
                                order[0].orderStatus.toString().toLowerCase() ==
                                            "done" ||
                                        order[0]
                                                .orderStatus
                                                .toString()
                                                .toLowerCase() ==
                                            "ready to deliver"
                                    ? Colors.green
                                    : Colors.red,
                            fontsize: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: CustomerOrderItemsView(
                  order: order[0],
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
