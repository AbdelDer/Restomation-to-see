import 'package:go_router/go_router.dart';
import 'package:restomation/MVVM/Views/Admin%20Screen/admin_screen.dart';
import 'package:restomation/MVVM/Views/Home%20Page/home_page.dart';
import 'package:restomation/MVVM/Views/Login%20Page/login_page.dart';
import 'package:restomation/MVVM/Views/Menu%20Category%20Page/menu_category_page.dart';
import 'package:restomation/MVVM/Views/OrderScreen/order_screen.dart';
import 'package:restomation/MVVM/Views/Resturant%20Details/resturant_details.dart';
import 'package:restomation/MVVM/Views/Staff%20page/staff_page.dart';
import 'package:restomation/MVVM/Views/Tables%20Page/tables_view.dart';

final GoRouter goRoute = GoRouter(
  routes: [
    GoRoute(
      name: "login",
      path: "/",
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      name: "home",
      path: "/home",
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: "restaurant-details",
      path: "/restaurant-details",
      builder: (context, state) => const RestaurantsDetailPage(),
    ),
    GoRoute(
      name: "menu",
      path: "/menu",
      builder: (context, state) => const MenuCategoryPage(),
    ),
    GoRoute(
      name: "tables",
      path: "/tables",
      builder: (context, state) => const TablesPage(),
    ),
    GoRoute(
      name: "staff",
      path: "/staff",
      builder: (context, state) => const StaffPage(),
    ),
    GoRoute(
      name: "orders",
      path: "/orders",
      builder: (context, state) => const OrderScreen(),
    ),
    GoRoute(
      name: "admins",
      path: "/admins",
      builder: (context, state) => const AdminScreen(),
    ),
  ],
);
