import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

class CustomerPage extends StatefulWidget {
  final String restaurantsKey;
  final String tableKey;
  const CustomerPage(
      {super.key, required this.restaurantsKey, required this.tableKey});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
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
              text: "Welcome to ${widget.restaurantsKey}",
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
            const CustomText(text: "Name :"),
            const SizedBox(
              height: 20,
            ),
            FormTextField(
                controller: nameController,
                suffixIcon: const Icon(Icons.email_outlined)),
            const SizedBox(
              height: 20,
            ),
            const CustomText(text: "Phone no :"),
            const SizedBox(
              height: 20,
            ),
            FormTextField(
                controller: phoneController,
                keyboardtype: TextInputType.number,
                suffixIcon: const Icon(Icons.numbers)),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: CustomButton(
                  buttonColor: primaryColor,
                  text: "Enter",
                  function: () {
                    Beamer.of(context).beamToNamed(
                        "/restaurants-menu-category/${widget.restaurantsKey},${widget.tableKey},${nameController.text},${phoneController.text}");
                  }),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
