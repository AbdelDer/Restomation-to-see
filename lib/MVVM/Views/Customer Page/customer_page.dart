import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

class CustomerPage extends StatefulWidget {
  final String resturantKey;
  final String resturantName;
  final String tableName;
  const CustomerPage(
      {super.key,
      required this.resturantKey,
      required this.resturantName,
      required this.tableName});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: BaseAppBar(
          title: "Restomation",
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            CustomText(
              text: "Welcome to ${widget.resturantName}",
              fontsize: 20,
              fontWeight: FontWeight.bold,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/splash.png",
                width: 200,
              ),
            ),
            const Spacer(),
            const CustomText(text: "Email :"),
            const SizedBox(
              height: 20,
            ),
            FormTextField(
                controller: controller,
                suffixIcon: const Icon(Icons.email_outlined)),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: CustomButton(
                  buttonColor: primaryColor,
                  text: "Enter",
                  function: () {
                    Beamer.of(context).beamToNamed(
                        "/resturant-menu-category/${widget.resturantName},${widget.resturantKey},${widget.tableName},${controller.text}");
                  }),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}