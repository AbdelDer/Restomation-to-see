import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/menu_page.dart';
import 'package:restomation/Provider/cart_provider.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_alert.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_loader.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_button.dart';
import '../../../Widgets/custom_cart_badge_icon.dart';

class MenuCategoryPage extends StatefulWidget {
  final String restaurantsKey;
  final String? tableKey;
  final String? name;
  final String? phone;
  final String? isTableClean;
  final String? addMoreItems;
  final String? orderItemsKey;
  final String? existingItemCount;
  const MenuCategoryPage({
    super.key,
    required this.restaurantsKey,
    this.tableKey,
    this.name,
    this.phone,
    this.isTableClean,
    required this.addMoreItems,
    this.orderItemsKey,
    this.existingItemCount,
  });

  @override
  State<MenuCategoryPage> createState() => _MenuCategoryPageState();
}

class _MenuCategoryPageState extends State<MenuCategoryPage>
    with TickerProviderStateMixin {
  bool isMounted = true;
  int indexCheck = 0;
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  showInfoDialogue() {
    if (widget.name != null) {
      Future.delayed(const Duration(seconds: 10), () async {
        if (isMounted) {
          final ref = StorageService.storage
              .ref()
              .child("/food_images/4202bd5f8f50e41a596812828f7dd65b.jpg");
          Alert(
              context: context,
              title: "Mini Falooda",
              style: AlertStyle(
                  overlayColor: kWhite.withOpacity(0.5),
                  backgroundColor: kWhite,
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
              closeIcon: const Icon(Icons.close),
              desc:
                  "A cold dessert popular in the Indian subcontinent, traditionally made from rose syrup, vermicelli, sweet basil seeds and pieces of jelly with milk",
              image: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  await ref.getDownloadURL(),
                  height: 200,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
              ),
              buttons: [
                DialogButton(
                    child: const CustomText(
                      text: "Ignore",
                      color: kWhite,
                    ),
                    onPressed: () {
                      KRoutes.pop(context);
                    }),
                DialogButton(
                    child: const CustomText(
                      text: "Add to Cart",
                      color: kWhite,
                    ),
                    onPressed: () {
                      context.read<Cart>().addCartItem({
                        "category": "Falooda",
                        "cookingStatus": "pending",
                        "description":
                            "A cold dessert popular in the Indian subcontinent, traditionally made from rose syrup, vermicelli, sweet basil seeds and pieces of jelly with milk",
                        "image":
                            "food_images/4202bd5f8f50e41a596812828f7dd65b.jpg",
                        "key": "-NLuXc1Hcbq-AV5f-Vq9",
                        "name": "Mini Falooda",
                        "price": "90",
                        "quantity": 1,
                        "rating": "0",
                        "reviews": "0",
                        "status": "available",
                        "type": "Veg",
                        "upselling": false
                      });
                      KRoutes.pop(context);
                    })
              ]).show();
        }
      });
    }
  }

  @override
  void initState() {
    showInfoDialogue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: "Menu",
          appBar: AppBar(),
          widgets: [
            if (widget.name == null)
              InkWell(
                onTap: () {
                  showCustomDialog(context);
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.add,
                      size: 30,
                      color: primaryColor,
                    ),
                    CustomText(
                      text: " Category",
                      fontsize: 20,
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
      bottomNavigationBar: (widget.name != null)
          ? CustomCartBadgeIcon(
              tableKey: widget.tableKey!,
              restaurantsKey: widget.restaurantsKey,
              name: widget.name!,
              phone: widget.phone!,
              isTableClean: widget.isTableClean!,
              addMoreItems: widget.addMoreItems,
              orderItemsKey: widget.orderItemsKey,
              existingItemCount: widget.existingItemCount,
            )
          : null,
      body: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child("menu_categories")
              .child(widget.restaurantsKey)
              .onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            return menuCategoryView(snapshot);
          }),
    );
  }

  Widget menuCategoryView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Center(child: Text("No categories Yet !!"));
    }
    Map allrestaurantsMenuCategories = snapshot.data!.snapshot.value as Map;
    List categoriesList = allrestaurantsMenuCategories.values.toList();
    TabController tabController = TabController(
        length: categoriesList.length, vsync: this, initialIndex: indexCheck);
    return DefaultTabController(
        length: categoriesList.length,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: TabBar(
                  isScrollable: true,
                  controller: tabController,
                  onTap: (index) {
                    indexCheck = index;
                  },
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: categoriesList
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomText(
                            text: e["categoryName"],
                            fontsize: 25,
                            fontWeight: FontWeight.bold,
                            color: kblack,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            body: TabBarView(
              controller: tabController,
              children: categoriesList
                  .map((e) => MenuPage(
                        restaurantsKey: widget.restaurantsKey,
                        categoryKey: e["categoryName"],
                        tableKey: widget.tableKey,
                        name: widget.name,
                        phone: widget.phone,
                        isTableClean: widget.isTableClean,
                        previousScreenContext: context,
                        addMoreItems: widget.addMoreItems,
                        orderItemsKey: widget.orderItemsKey,
                        existingItemCount: widget.existingItemCount,
                      ))
                  .toList(),
            )));
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
                                    widget.restaurantsKey,
                                    categoryController.text)
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
    isMounted = false;
    categoryController.dispose();
    controller.dispose();
    super.dispose();
  }
}
