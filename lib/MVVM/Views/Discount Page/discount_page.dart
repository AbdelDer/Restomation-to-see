import 'package:flutter/material.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';

class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: "Special discounts for You !!",
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Column(
        children: const [],
      ),
    );
  }
}
