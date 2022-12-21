import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Models/Menu%20Category%20Model/menu_category_model.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';

class SelectedCategoryProvider with ChangeNotifier {
  List<MenuTabCategory> tabs = [];
  List<MenuTabObject> items = [];
  double offSetFrom = 0.0;
  double offSetTo = 0.0;
  late TabController tabController;
  ScrollController scrollController = ScrollController();
  void init(TickerProvider ticker, List<MenuCategoryModel> allrestaurantsMenuCategories) {
    tabController = TabController(length: allrestaurantsMenuCategories.length, vsync: ticker);
    for (var i = 0; i < allrestaurantsMenuCategories.length; i++) {
      final MenuCategoryModel menuCategoryModel = allrestaurantsMenuCategories[i];

      if (i > 0) {
        offSetFrom += (allrestaurantsMenuCategories[i - 1].menuModel ?? []).length * 190;
      }
      if (i < allrestaurantsMenuCategories.length - 1) {
        offSetTo = offSetFrom + (allrestaurantsMenuCategories[i + 1].menuModel ?? []).length * 190;
      } else {
        offSetTo = double.infinity;
      }

      tabs.add(
        MenuTabCategory(categoryModel: menuCategoryModel, selected: i == 0, offSet: (i == 0) ? 0 : 50 + offSetFrom, offSetTo: offSetTo),
      );
      items.add(MenuTabObject(menuCategoryModel: menuCategoryModel));
      for (var j = 0; j < (menuCategoryModel.menuModel ?? []).length; j++) {
        final product = (menuCategoryModel.menuModel ?? [])[j];
        items.add(MenuTabObject(menuModel: product));
      }
      scrollController.addListener(scrollControllerListener);
    }
  }

  void scrollControllerListener() {
    for (var i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      if (scrollController.offset >= tab.offSet && scrollController.offset <= tab.offSetTo && !tab.selected) {
        onCategorySelected(i);
        tabController.animateTo(i);
        break;
      }
    }
  }

  void onCategorySelected(int index) {
    final selected = tabs[index];
    for (var i = 0; i < tabs.length; i++) {
      tabs[i] = tabs[i].copyWith(selected.categoryModel.categoryName == tabs[i].categoryModel.categoryName);
    }
    notifyListeners();
    scrollController.animateTo(
      selected.offSet,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollControllerListener);
    tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

class MenuTabCategory {
  MenuTabCategory({required this.categoryModel, required this.selected, required this.offSet, required this.offSetTo});
  MenuTabCategory copyWith(bool selected) => MenuTabCategory(categoryModel: categoryModel, selected: selected, offSet: offSet, offSetTo: offSetTo);
  final MenuCategoryModel categoryModel;
  final bool selected;
  final double offSet;
  final double offSetTo;
}

class MenuTabObject {
  final MenuCategoryModel? menuCategoryModel;
  final MenuModel? menuModel;
  MenuTabObject({
    this.menuCategoryModel,
    this.menuModel,
  });
  bool get isCategory => menuCategoryModel != null;
}
