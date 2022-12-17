import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/Menu%20Category%20Model/menu_category_model.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';
import 'package:restomation/MVVM/Models/RestaurantsModel/restaurants_model.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/food_card.dart';
import 'package:restomation/Provider/selected_category_provider.dart';
import 'package:restomation/Provider/selected_restaurant_provider.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_alert.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_button.dart';
import '../../Repo/Menu Service/menu_service.dart';

class MenuCategoryPage extends StatefulWidget {
  const MenuCategoryPage({
    super.key,
  });

  @override
  State<MenuCategoryPage> createState() => _MenuCategoryPageState();
}

class _MenuCategoryPageState extends State<MenuCategoryPage>
    with TickerProviderStateMixin {
  int indexCheck = 0;
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  final SelectedCategoryProvider selectedCategoryProvider =
      SelectedCategoryProvider();
  @override
  Widget build(BuildContext context) {
    RestaurantModel? restaurantModel =
        context.read<SelectedRestaurantProvider>().restaurantModel;

    return Scaffold(
      appBar: BaseAppBar(
          title: "Menu",
          appBar: AppBar(),
          widgets: const [
            // if (widget.name == null)
            //   InkWell(
            //     onTap: () {
            //       showCustomDialog(context);
            //     },
            //     child: Row(
            //       children: const [
            //         Icon(
            //           Icons.add,
            //           size: 30,
            //           color: primaryColor,
            //         ),
            //         CustomText(
            //           text: " Category",
            //           fontsize: 20,
            //           color: primaryColor,
            //         ),
            //       ],
            //     ),
            //   ),
            // const SizedBox(
            //   width: 20,
            // ),
          ],
          appBarHeight: 50),
      // bottomNavigationBar: (widget.name != null)
      //     ? CustomCartBadgeIcon(
      //         tableKey: widget.tableKey!,
      //         restaurantsKey: widget.restaurantsKey,
      //         name: widget.name!,
      //         phone: widget.phone!,
      //         isTableClean: widget.isTableClean!,
      //         addMoreItems: widget.addMoreItems,
      //         orderItemsKey: widget.orderItemsKey,
      //         existingItemCount: widget.existingItemCount,
      //       )
      //     : null,
      body: StreamBuilder(
          stream: MenuService().getMenu(restaurantModel?.id ?? ""),
          builder: (context, AsyncSnapshot<List<MenuCategoryModel>> snapshot) {
            return menuCategoryView(snapshot);
          }),
    );
  }

  Widget menuCategoryView(AsyncSnapshot<List<MenuCategoryModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.data!.isEmpty) {
      return const Center(child: Text("No categories Yet !!"));
    }
    List<MenuCategoryModel> allrestaurantsMenuCategories = snapshot.data!;
    selectedCategoryProvider.init(this, allrestaurantsMenuCategories);

    return AnimatedBuilder(
      animation: selectedCategoryProvider,
      builder: (context, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: kGrey.shade100,
            height: 60,
            child: TabBar(
              controller: selectedCategoryProvider.tabController,
              onTap: (index) {
                selectedCategoryProvider.onCategorySelected(index);
              },
              indicatorWeight: 0.1,
              isScrollable: true,
              tabs: selectedCategoryProvider.tabs
                  .map((e) => CustomTabbarWidget(
                        menuTabCategory: e,
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: selectedCategoryProvider.items.length,
              itemBuilder: (context, index) {
                final item = selectedCategoryProvider.items[index];
                if (item.isCategory) {
                  return CustomMenuCategoryWidget(
                      menuCategoryModel: item.menuCategoryModel!);
                } else {
                  return CustomMenuItemsWidget(menuModel: item.menuModel!);
                }
              },
            ),
            // child: VerticalTabBarView(
            //   controller: tabController,
            //   children: allrestaurantsMenuCategories
            //       .map((e) => Padding(
            //             padding: const EdgeInsets.all(12),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 CustomText(
            //                   text: e.categoryName ?? "No name",
            //                   fontsize: 20,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //                 MenuPage(
            //                   itemsList: e.menuModel ?? [],
            //                 ),
            //               ],
            //             ),
            //           ))
            //       .toList(),
            // ),
          ),
        ],
      ),
    );
  }

  void showCustomDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            content: SizedBox(
              width: 300,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(text: "Create Category"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: categoryController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Fill this field";
                        }
                        return null;
                      },
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        buttonColor: primaryColor,
                        text: "create",
                        textColor: kWhite,
                        function: () async {
                          if (!formKey.currentState!.validate()) {
                            Fluttertoast.showToast(msg: "Field can't be empty");
                          } else {
                            Alerts.customLoadingAlert(context);
                            await DatabaseService.createCategory(
                                    "", categoryController.text)
                                .then((value) {
                              KRoutes.pop(context);
                              return KRoutes.pop(context);
                            });
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
    selectedCategoryProvider.dispose();
    categoryController.dispose();
    controller.dispose();
    super.dispose();
  }
}

class CustomTabbarWidget extends StatelessWidget {
  final MenuTabCategory menuTabCategory;
  const CustomTabbarWidget({super.key, required this.menuTabCategory});

  @override
  Widget build(BuildContext context) {
    final selected = menuTabCategory.selected;
    return Opacity(
      opacity: selected ? 1 : 0.5,
      child: Card(
        elevation: selected ? 6 : 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: CustomText(
              text: menuTabCategory.categoryModel.categoryName ?? "unknown",
              fontWeight: FontWeight.bold,
              fontsize: 13),
        ),
      ),
    );
  }
}

class CustomMenuCategoryWidget extends StatelessWidget {
  final MenuCategoryModel menuCategoryModel;
  const CustomMenuCategoryWidget({super.key, required this.menuCategoryModel});

  @override
  Widget build(BuildContext context) {
    return CustomText(
        text: menuCategoryModel.categoryName ?? "unknown",
        fontWeight: FontWeight.bold,
        fontsize: 20);
  }
}

class CustomMenuItemsWidget extends StatelessWidget {
  final MenuModel menuModel;
  const CustomMenuItemsWidget({super.key, required this.menuModel});

  @override
  Widget build(BuildContext context) {
    return CustomFoodCard(item: menuModel);
  }
}
