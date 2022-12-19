import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/Menu%20Category%20Model/menu_category_model.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';
import 'package:restomation/MVVM/Models/RestaurantsModel/restaurants_model.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/food_card.dart';
import 'package:restomation/Provider/selected_category_provider.dart';
import 'package:restomation/Provider/selected_restaurant_provider.dart';
import 'package:restomation/Utils/Helper%20Functions/essential_functions.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import '../../../Utils/contants.dart';
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
          widgets: [
            InkWell(
              onTap: () {
                EssentialFunctions().createCategoryDialog(
                    context, categoryController, restaurantModel?.id ?? "");
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.add_outlined,
                    size: 20,
                    color: primaryColor,
                  ),
                  CustomText(
                    text: " Category",
                    fontsize: 15,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
          appBarHeight: 50),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const CustomText(
            text: "+ Add Items",
            color: kWhite,
          )),
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
    if (snapshot.data == null) {
      return const Center(child: Text("An Error occured !!"));
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
              controller: selectedCategoryProvider.scrollController,
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
