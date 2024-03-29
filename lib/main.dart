import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restomation/MVVM/View%20Model/Admin%20View%20Model/admin_view_model.dart';
import 'package:restomation/MVVM/View%20Model/Category%20View%20Model/category_view_model.dart';
import 'package:restomation/MVVM/View%20Model/Login%20View%20Model/login_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:restomation/MVVM/View%20Model/Staff%20View%20Model/staff_view_model.dart';
import 'package:restomation/MVVM/View%20Model/Tables%20View%20Model/tables_view_model.dart';
import 'package:restomation/MVVM/Views/Home%20Page/home_page.dart';
import 'package:restomation/MVVM/Views/Login%20Page/login_page.dart';
import 'package:restomation/Provider/cart_provider.dart';
import 'package:restomation/Utils/go_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'MVVM/View Model/Order View Model/order_view_model.dart';
import 'MVVM/View Model/Resturants View Model/resturants_view_model.dart';
import 'Provider/selected_restaurant_provider.dart';
import 'Provider/customer_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setPathUrlStrategy();
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
          create: (context) => TablesViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => SelectedRestaurantProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => MenuCategoryViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => StaffViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerProvider(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            dividerColor: Colors.transparent,
            textTheme: GoogleFonts.poppinsTextTheme()),
        routerDelegate: goRoute.routerDelegate,
        routeInformationParser: goRoute.routeInformationParser,
      ),
    );
  }
}
