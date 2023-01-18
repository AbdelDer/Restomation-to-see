import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/Repo/RestaurantService/restaurant_service.dart';
import 'package:restomation/MVVM/View%20Model/Login%20View%20Model/login_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:restomation/MVVM/Views/Admin%20Screen/admin_screen.dart';
import 'package:restomation/MVVM/Views/Cart/cart.dart';
import 'package:restomation/MVVM/Views/Customer%20Page/customer_page.dart';
import 'package:restomation/MVVM/Views/Home%20Page/home_page.dart';
import 'package:restomation/MVVM/Views/Login%20Page/login_page.dart';
import 'package:restomation/MVVM/Views/Menu%20Category%20Page/menu_category_page.dart';
import 'package:restomation/MVVM/Views/OrderScreen/order_screen.dart';
import 'package:restomation/MVVM/Views/Staff%20page/staff_page.dart';
import 'package:restomation/MVVM/Views/Tables%20Page/tables_view.dart';
import 'package:restomation/Provider/cart_provider.dart';
import 'MVVM/View Model/Resturants View Model/resturants_view_model.dart';
import 'MVVM/Views/Customer Order Page/customer_order_page.dart';
import 'MVVM/Views/Resturant Details/resturant_details.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    setCache();
    super.initState();
  }

  setCache() async {
    var box = await Hive.openBox('cache');
    await box.put("first_time", true);
  }

  final routerDelegate = BeamerDelegate(
      initialPath: "/login",
      locationBuilder: RoutesLocationBuilder(routes: {
        "/login": (p0, p1, p2) => const BeamPage(
              key: ValueKey("login"),
              title: "Login",
              type: BeamPageType.scaleTransition,
              child: Login(),
            ),
        "/home": (p0, p1, p2) => const BeamPage(
              key: ValueKey("home"),
              title: "Home",
              type: BeamPageType.fadeTransition,
              child: HomePage(),
            ),
        "/restaurants-details/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");
          return BeamPage(
            key: ValueKey(parameters[0]),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: RestaurantsDetailPage(
              restaurantsKey: parameters[0],
              restaurantsImageName: parameters[1],
            ),
          );
        },
        "/restaurants-menu-category/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");

          return BeamPage(
            key: const ValueKey("menu-category"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: parameters.length == 2
                ? MenuCategoryPage(
                    restaurantsKey: parameters[0],
                    addMoreItems: parameters[1],
                  )
                : MenuCategoryPage(
                    restaurantsKey: parameters[0],
                    tableKey: parameters[1],
                    name: parameters[2],
                    phone: parameters[3],
                    isTableClean: parameters[4],
                    addMoreItems: parameters[5],
                    orderItemsKey: parameters[6],
                    existingItemCount: parameters[7],
                  ),
          );
        },
        "/restaurants-tables/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");
          return BeamPage(
            key: const ValueKey("restaurants-tables"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: TablesPage(
              restaurantsKey: parameters[0],
              restaurantsImageName: parameters[1],
            ),
          );
        },
        "/restaurants-staff/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");
          return BeamPage(
              key: const ValueKey("staff"),
              title: parameters[0],
              type: BeamPageType.fadeTransition,
              child: StaffPage(
                restaurantsKey: parameters[0],
              ));
        },
        "/restaurants-admins/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");
          return BeamPage(
              key: const ValueKey("staff"),
              title: parameters[0],
              type: BeamPageType.fadeTransition,
              child: AdminScreen(
                restaurantsKey: parameters[0],
                restaurantImageName: parameters[1],
              ));
        },
        "/restaurants-orders/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");
          return BeamPage(
            key: const ValueKey("orders"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: OrderScreen(
              restaurantsKey: parameters[0],
            ),
          );
        },
        "/customer-table/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");
          return BeamPage(
            key: const ValueKey("customer-table"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: CustomerPage(
              restaurantsKey: parameters[0],
              tableKey: parameters[1],
              restaurantsImageName: parameters[2],
            ),
          );
        },
        "/customer-cart/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");
          return BeamPage(
              key: const ValueKey("customer-cart"),
              title: parameters[0],
              type: BeamPageType.fadeTransition,
              child: CartPage(
                restaurantsKey: parameters[0],
                tableKey: parameters[1],
                name: parameters[2],
                phone: parameters[3],
                isTableClean: parameters[4],
                addMoreItems: parameters[5],
                orderItemsKey: parameters[6],
                existingItemCount: parameters[7],
              ));
        },
        "/customer-order/:parameters": (p0, p1, p2) {
          final String restaurantsParams =
              p1.pathParameters["parameters"] ?? "";
          List<String> parameters = restaurantsParams.split(",");
          return BeamPage(
              key: const ValueKey("customer-order"),
              title: parameters[0],
              type: BeamPageType.fadeTransition,
              child: CustomerOrderPage(
                restaurantsKey: parameters[0],
                tableKey: parameters[1],
                name: parameters[2],
                phone: parameters[3],
              ));
        }
      }));
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantsViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantService(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            dividerColor: Colors.transparent,
            textTheme: GoogleFonts.poppinsTextTheme()),
        routeInformationParser: BeamerParser(),
        routerDelegate: routerDelegate,
      ),
    );
  }
}
