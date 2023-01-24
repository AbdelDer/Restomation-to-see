import 'package:go_router/go_router.dart';
import 'package:restomation/MVVM/Views/Admin%20Screen/admin_screen.dart';
import 'package:restomation/MVVM/Views/Cart/cart.dart';
import 'package:restomation/MVVM/Views/Customer%20Menu%20Page/customer_menu_page.dart';
import 'package:restomation/MVVM/Views/Customer%20Order%20Page/customer_order_page.dart';
import 'package:restomation/MVVM/Views/Customer%20Page/customer_page.dart';
import 'package:restomation/MVVM/Views/Customer%20Page/page_decider.dart';
import 'package:restomation/MVVM/Views/Home%20Page/home_page.dart';
import 'package:restomation/MVVM/Views/Login%20Page/login_page.dart';
import 'package:restomation/MVVM/Views/Menu%20Page/menu_page.dart';
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
    GoRoute(
      name: "page-decider",
      path: "/page-decider/:param",
      builder: (context, state) {
        List param = (state.params["param"] as String).split(",").toList();
        return PageDecider(
          restaurantKey: param[0] ?? "",
          tableKey: param[1] ?? "",
        );
      },
    ),
    GoRoute(
      name: "customer-page",
      path: "/customer-page/:param",
      builder: (context, state) {
        List param = (state.params["param"] as String).split(",").toList();
        return CustomerPage(
          restaurantKey: param[0] ?? "",
          tableKey: param[1] ?? "",
        );
      },
    ),
    GoRoute(
      name: "customer-menu-page",
      path: "/customer-menu-page",
      builder: (context, state) => const CustomerMenuPage(),
    ),
    GoRoute(
      name: "cart-page",
      path: "/cart-page",
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      name: "customer-order-page",
      path: "/customer-order-page/:param",
      builder: (context, state) {
        List param = (state.params["param"] as String).split(",").toList();
        return CustomerOrderPage(
          restaurantKey: param[0] ?? "",
          tableKey: param[1] ?? "",
        );
      },
    ),
  ],
);
