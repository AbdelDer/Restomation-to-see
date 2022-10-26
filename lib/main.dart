import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/View%20Model/Login%20View%20Model/login_view_model.dart';
import 'package:restomation/MVVM/View%20Model/Resturants%20View%20Model/resturants_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:restomation/MVVM/Views/Cart/cart.dart';
import 'package:restomation/MVVM/Views/Customer%20Page/customer_page.dart';
import 'package:restomation/MVVM/Views/Home%20Page/home_page.dart';
import 'package:restomation/MVVM/Views/Login%20Page/login_page.dart';
import 'package:restomation/MVVM/Views/Menu%20Category%20Page/menu_category_page.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/menu_page.dart';
import 'package:restomation/MVVM/Views/OrderScreen/order_screen.dart';
import 'package:restomation/MVVM/Views/Resturant%20Details/resturant_details.dart';
import 'package:restomation/MVVM/Views/Staff%20Category%20Page/staff_category_page.dart';
import 'package:restomation/MVVM/Views/Staff%20page/staff_page.dart';
import 'package:restomation/MVVM/Views/Tables%20Page/tables_view.dart';
import 'package:restomation/Provider/cart_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        "/resturant-details/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
            key: ValueKey(parameters[0]),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: ResturantDetailPage(
              resturantName: parameters[0],
              resturantKey: parameters[1],
            ),
          );
        },
        "/resturant-menu-category/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
            key: const ValueKey("menu-category"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: parameters.length == 2
                ? MenuCategoryPage(
                    resturantName: parameters[0],
                    resturantKey: parameters[1],
                  )
                : MenuCategoryPage(
                    resturantName: parameters[0],
                    resturantKey: parameters[1],
                    tableName: parameters[2],
                    email: parameters[3],
                  ),
          );
        },
        "/resturant-menu-category/menu/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
            key: const ValueKey("menu"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: parameters.length == 2
                ? MenuPage(
                    resturantKey: parameters[0],
                    categoryKey: parameters[1],
                  )
                : MenuPage(
                    resturantKey: parameters[0],
                    categoryKey: parameters[1],
                    tableName: parameters[2],
                    email: parameters[3],
                  ),
          );
        },
        "/resturant-tables/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
            key: const ValueKey("resturant-tables"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: TablesPage(
              resturantName: parameters[0],
              resturantKey: parameters[1],
            ),
          );
        },
        "/resturant-staff-category/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
              key: const ValueKey("staff-category"),
              title: parameters[0],
              type: BeamPageType.fadeTransition,
              child: StaffCategoryPage(
                resturantName: parameters[0],
                resturantKey: parameters[1],
              ));
        },
        "/resturant-staff-category/staff/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
              key: const ValueKey("staff"),
              title: parameters[0],
              type: BeamPageType.fadeTransition,
              child: StaffPage(
                resturantName: parameters[0],
                resturantKey: parameters[1],
                staffCategoryName: parameters[2],
                staffCategoryKey: parameters[3],
              ));
        },
        "/resturant-orders/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
            key: const ValueKey("orders"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: OrderScreen(
              resturantName: parameters[0],
              resturantKey: parameters[1],
            ),
          );
        },
        "/customer-table/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
            key: const ValueKey("customer-table"),
            title: parameters[0],
            type: BeamPageType.fadeTransition,
            child: CustomerPage(
              resturantKey: parameters[0],
              tableKey: parameters[1],
            ),
          );
        },
        "/customer-cart/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
              key: const ValueKey("customer-cart"),
              title: parameters[0],
              type: BeamPageType.fadeTransition,
              child: CartPage(
                  resturantKey: parameters[1],
                  tableName: parameters[2],
                  customer: parameters[3]));
        },
        "/customer-order/:parameters": (p0, p1, p2) {
          final String resturantParams = p1.pathParameters["parameters"] ?? "";
          List<String> parameters = resturantParams.split(",");
          return BeamPage(
              key: const ValueKey("customer-cart"),
              title: parameters[0],
              type: BeamPageType.fadeTransition,
              child: CartPage(
                  resturantKey: parameters[1],
                  tableName: parameters[2],
                  customer: parameters[3]));
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
          create: (context) => ResturantViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
      ],
      child: MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: routerDelegate,
      ),
    );
  }
}
