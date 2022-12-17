import 'package:flutter/material.dart';
import 'package:restomation/MVVM/Models/Menu%20Category%20Model/menu_category_model.dart';
import 'package:restomation/MVVM/Models/Menu%20Model/menu_model.dart';

class SelectedCategoryProvider with ChangeNotifier {
  List<MenuTabCategory> tabs = [];
  List<MenuTabObject> items = [];
  late TabController tabController;
  late ScrollController scrollController;
  void init(TickerProvider ticker,
      List<MenuCategoryModel> allrestaurantsMenuCategories) {
    tabController = TabController(
        length: allrestaurantsMenuCategories.length, vsync: ticker);
    for (var i = 0; i < allrestaurantsMenuCategories.length; i++) {
      MenuCategoryModel menuCategoryModel = allrestaurantsMenuCategories[i];
      tabs.add(
          MenuTabCategory(categoryModel: menuCategoryModel, selected: i == 0));
      items.add(MenuTabObject(menuCategoryModel: menuCategoryModel));
      for (var j = 0; j < (menuCategoryModel.menuModel ?? []).length; j++) {
        final product = (menuCategoryModel.menuModel ?? [])[j];
        items.add(MenuTabObject(menuModel: product));
      }
    }
  }

  void onCategorySelected(int index) {
    final selected = tabs[index];
    for (var i = 0; i < tabs.length; i++) {
      tabs[i] = tabs[i].copyWith(selected.categoryModel.categoryName ==
          tabs[i].categoryModel.categoryName);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

class MenuTabCategory {
  MenuTabCategory({required this.categoryModel, required this.selected});
  MenuTabCategory copyWith(bool selected) =>
      MenuTabCategory(categoryModel: categoryModel, selected: selected);
  final MenuCategoryModel categoryModel;
  final bool selected;
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
