import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Models/Menu%20Category%20Model/menu_category_model.dart';
import 'package:restomation/MVVM/View%20Model/Resturants%20View%20Model/resturants_view_model.dart';
import 'package:restomation/MVVM/Views/Customer%20Menu%20Page/customer_menu_food_card.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_cart_badge_icon.dart';
import '../../Repo/Menu Service/menu_service.dart';

class CustomerMenuPage extends StatefulWidget {
  const CustomerMenuPage({
    super.key,
  });

  @override
  State<CustomerMenuPage> createState() => _CustomerMenuPageState();
}

class _CustomerMenuPageState extends State<CustomerMenuPage>
    with TickerProviderStateMixin {
  int indexCheck = 0;

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController menuItemNameController = TextEditingController();
  final TextEditingController menuItemPriceController = TextEditingController();
  final TextEditingController menuItemDescriptionController =
      TextEditingController();
  final TextEditingController controller = TextEditingController();
  final TextEditingController menuItemTypeController = TextEditingController();
  final TextEditingController mennuItemSelectedCategory =
      TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<double> offsetList = [];
  late TabController tabController;

  void scrollListener() {
    for (var i = 0; i < offsetList.length; i++) {
      if (i < offsetList.length - 1) {
        if (scrollController.offset > offsetList[i] &&
            scrollController.offset < offsetList[i + 1]) {
          tabController.animateTo(i);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    RestaurantsViewModel restaurantsViewModel =
        context.read<RestaurantsViewModel>();

    return Scaffold(
      appBar: BaseAppBar(
          title: "Menu", appBar: AppBar(), widgets: const [], appBarHeight: 50),
      bottomNavigationBar: const CustomCartBadgeIcon(),
      body: StreamBuilder(
          stream: MenuService()
              .getMenu(restaurantsViewModel.restaurantModel?.id ?? ""),
          builder: (context, AsyncSnapshot<List<MenuCategoryModel>> snapshot) {
            return menuCategoryView(snapshot, restaurantsViewModel);
          }),
    );
  }

  Widget menuCategoryView(AsyncSnapshot<List<MenuCategoryModel>> snapshot,
      RestaurantsViewModel restaurantsViewModel) {
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

    offsetList = getListOffsets(allrestaurantsMenuCategories);
    tabController =
        TabController(length: allrestaurantsMenuCategories.length, vsync: this);

    return Column(
      children: [
        TabBar(
          controller: tabController,
          onTap: (value) async {
            double offset = 0;
            for (var i = 0; i < allrestaurantsMenuCategories.length; i++) {
              if (allrestaurantsMenuCategories[i].categoryName ==
                  allrestaurantsMenuCategories[value].categoryName) {
                int j = i - 1;
                for (j; j >= 0; j--) {
                  offset += 60 +
                      ((allrestaurantsMenuCategories[j].menuItemModel ?? [])
                              .length *
                          190);
                }
                tabController.animateTo(value);
                scrollController.removeListener(scrollListener);
                await scrollController.animateTo(offset,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
                scrollController.addListener(scrollListener);
                break;
              }
            }
          },
          isScrollable: true,
          tabs: allrestaurantsMenuCategories
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Text(
                      e.categoryName ?? "",
                      style: const TextStyle(
                        color: kblack,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
              .toList(),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            itemCount: allrestaurantsMenuCategories.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        CustomText(
                          text: allrestaurantsMenuCategories[index]
                                  .categoryName ??
                              "",
                          fontsize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        const Expanded(
                            child: Divider(
                          endIndent: 20,
                          indent: 20,
                          thickness: 1,
                          color: kGrey,
                        ))
                      ],
                    ),
                  ),
                  Column(
                    children: allrestaurantsMenuCategories[index]
                            .menuItemModel
                            ?.map((e) => CustomerMenuFoodCard(item: e))
                            .toList() ??
                        [],
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<double> getListOffsets(
      List<MenuCategoryModel> allrestaurantsMenuCategories) {
    List<double> offsetListDuplicate = [];

    for (var i = 0; i < allrestaurantsMenuCategories.length; i++) {
      double localOffSet = 0;
      if (i > 0) {
        int j = i - 1;
        for (j; j >= 0; j--) {
          localOffSet += 60 +
              ((allrestaurantsMenuCategories[j].menuItemModel ?? []).length *
                  190);
        }
      }
      offsetListDuplicate.add(localOffSet);
    }

    return offsetListDuplicate;
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    tabController.dispose();
    categoryController.dispose();
    menuItemNameController.dispose();
    menuItemDescriptionController.dispose();
    menuItemPriceController.dispose();
    menuItemTypeController.dispose();
    mennuItemSelectedCategory.dispose();
    controller.dispose();
    super.dispose();
  }
}
