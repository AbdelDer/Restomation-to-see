import 'package:go_router/go_router.dart';
import 'package:restomation/MVVM/Views/Home%20Page/home_page.dart';
import 'package:restomation/MVVM/Views/Login%20Page/login_page.dart';

final GoRouter route = GoRouter(routes: [
  GoRoute(
    path: "/",
    routes: [
      GoRoute(
        path: "home",
        builder: (context, state) => const HomePage(),
      ),
    ],
    builder: (context, state) => const Login(),
  ),
]);
