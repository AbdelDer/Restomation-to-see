import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Models/Menu%20Category%20Model/menu_category_model.dart';
import 'package:restomation/MVVM/Models/RestaurantsModel/restaurants_model.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/menu_page.dart';
import 'package:restomation/Utils/Helper%20Functions/essential_functions.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import '../../../Utils/contants.dart';
import '../../Repo/Menu Service/menu_service.dart';

class MenuCategoryPage extends StatefulWidget {
  final RestaurantModel restaurantModel;
  const MenuCategoryPage({
    super.key,
    required this.restaurantModel,
  });

  @override
  State<MenuCategoryPage> createState() => _MenuCategoryPageState();
}

class _MenuCategoryPageState extends State<MenuCategoryPage>
    with TickerProviderStateMixin {
  int indexCheck = 0;

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController controller = TextEditingController();
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
    scrollController.addListener(scrollListener);

    return Scaffold(
      appBar: BaseAppBar(
          title: "Menu",
          appBar: AppBar(),
          widgets: [
            InkWell(
              onTap: () {
                EssentialFunctions().createCategoryDialog(context,
                    categoryController, widget.restaurantModel.id ?? "");
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
          onPressed: () async {
            // EssentialFunctions().createMenuItemDialog(context, categoryController, restaurantModel!.id!);
          },
          label: const CustomText(
            text: "+ Add Items",
            color: kWhite,
          )),
      body: StreamBuilder(
          stream: MenuService().getMenu(widget.restaurantModel.id ?? ""),
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
                      ((allrestaurantsMenuCategories[j].menuModel ?? [])
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
            padding: const EdgeInsets.symmetric(vertical: 10),
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
                  MenuPage(
                      itemsList:
                          allrestaurantsMenuCategories[index].menuModel ?? [])
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
              ((allrestaurantsMenuCategories[j].menuModel ?? []).length * 190);
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
    controller.dispose();
    super.dispose();
  }
}
