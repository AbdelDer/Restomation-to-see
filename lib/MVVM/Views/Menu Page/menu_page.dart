import 'package:flutter/material.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'food_card.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    List dataList = [
      {
        "name": "Sambar Rice",
        "price": "₹100",
        "rating": 4.2,
        "description": "A typical South Indian mildy spicy sambar rice ...",
        "image":
            "https://www.archanaskitchen.com/images/archanaskitchen/0-Archanas-Kitchen-Recipes/Mixed_Vegetable_Sambar_Rice-5.jpg",
        "reviews": "(142)",
      },
      {
        "name": "Curd Rice",
        "price": "₹100",
        "rating": 4.2,
        "description": "A simple yummy rice dish made of soft cooked rich ...",
        "image":
            "https://tastedrecipes.com/wp-content/uploads/2021/01/south-indian-curd-rice-2.jpg",
        "reviews": "(94)",
      },
      {
        "name": "Mini Lunch",
        "price": "₹180",
        "rating": 4.2,
        "description":
            "A tasty traditional mini launch platter comprising of ...",
        "image":
            "https://image.made-in-china.com/155f0j00DlpfNHGRmUqT/25PCS-Disposable-Compartment-Small-Business-Mini-Lunch-Box-Fruit-Fishing-Light-Food-Fitness-Meal.jpg",
        "reviews": "(304)",
      },
      {
        "name": "Sambar Rice",
        "price": "₹100",
        "rating": 4.2,
        "description": "A typical South Indian mildy spicy sambar rice ...",
        "image":
            "https://www.archanaskitchen.com/images/archanaskitchen/0-Archanas-Kitchen-Recipes/Mixed_Vegetable_Sambar_Rice-5.jpg",
        "reviews": "(142)",
      },
      {
        "name": "Curd Rice",
        "price": "₹100",
        "rating": 4.2,
        "description": "A simple yummy rice dish made of soft cooked rich ...",
        "image":
            "https://tastedrecipes.com/wp-content/uploads/2021/01/south-indian-curd-rice-2.jpg",
        "reviews": "(94)",
      },
      {
        "name": "Mini Lunch",
        "price": "₹180",
        "rating": 4.2,
        "description":
            "A tasty traditional mini launch platter comprising of ...",
        "image":
            "https://image.made-in-china.com/155f0j00DlpfNHGRmUqT/25PCS-Disposable-Compartment-Small-Business-Mini-Lunch-Box-Fruit-Fishing-Light-Food-Fitness-Meal.jpg",
        "reviews": "(304)",
      },
      {
        "name": "Sambar Rice",
        "price": "₹100",
        "rating": 4.2,
        "description": "A typical South Indian mildy spicy sambar rice ...",
        "image":
            "https://www.archanaskitchen.com/images/archanaskitchen/0-Archanas-Kitchen-Recipes/Mixed_Vegetable_Sambar_Rice-5.jpg",
        "reviews": "(142)",
      },
      {
        "name": "Curd Rice",
        "price": "₹100",
        "rating": 4.2,
        "description": "A simple yummy rice dish made of soft cooked rich ...",
        "image":
            "https://tastedrecipes.com/wp-content/uploads/2021/01/south-indian-curd-rice-2.jpg",
        "reviews": "(94)",
      },
      {
        "name": "Mini Lunch",
        "price": "₹180",
        "rating": 4.2,
        "description":
            "A tasty traditional mini launch platter comprising of ...",
        "image":
            "https://image.made-in-china.com/155f0j00DlpfNHGRmUqT/25PCS-Disposable-Compartment-Small-Business-Mini-Lunch-Box-Fruit-Fishing-Light-Food-Fitness-Meal.jpg",
        "reviews": "(304)",
      },
    ];

    return Scaffold(
      appBar: BaseAppBar(
        title: "Menu",
        appBar: AppBar(),
        widgets: const [],
        appBarHeight: 50,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {}, label: const CustomText(text: "Add Item")),
      body: Center(
        child: SizedBox(
          width: 450,
          child: ListView.separated(
              itemBuilder: (context, index) =>
                  CustomFoodCard(data: dataList[index]),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: dataList.length),
        ),
      ),
    );
  }
}
