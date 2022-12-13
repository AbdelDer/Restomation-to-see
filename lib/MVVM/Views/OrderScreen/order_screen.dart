import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Views/OrderScreen/filtered_orders.dart';
import 'package:restomation/MVVM/Views/OrderScreen/running_orders.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_text.dart';

import '../../../Utils/contants.dart';

class OrderScreen extends StatefulWidget {
  final String restaurantsKey;
  const OrderScreen({super.key, required this.restaurantsKey});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  late TabController? tabController;

  @override
  Widget build(BuildContext context) {
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    return Scaffold(
      appBar: BaseAppBar(
        title: widget.restaurantsKey,
        appBar: AppBar(),
        widgets: const [],
        appBarHeight: 50,
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: "All Orders :",
                fontWeight: FontWeight.bold,
                fontsize: 25,
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        controller: tabController,
                        labelColor: kblack,
                        tabs: const [
                          Tab(
                            text: "Running Orders",
                          ),
                          Tab(
                            text: "Completed Orders",
                          ),
                          Tab(
                            text: "Cancelled Orders",
                          )
                        ],
                      ),
                      Expanded(
                        child: TabBarView(controller: tabController, children: [
                          RunningOrderScreen(
                              restaurantsKey: widget.restaurantsKey),
                          FilteredOrderScreen(
                            restaurantsKey: widget.restaurantsKey,
                            filteredOrderType: 'completed-orders',
                          ),
                          FilteredOrderScreen(
                            restaurantsKey: widget.restaurantsKey,
                            filteredOrderType: 'cancelled_orders',
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
