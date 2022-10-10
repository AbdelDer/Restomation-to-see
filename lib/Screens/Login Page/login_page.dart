import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/Screens/Home%20Page/home_page.dart';
import 'package:restomation/Utils/app_routes.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: "Login",
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: loginView(context)),
          ),
        ),
      ),
    );
  }

  Widget loginView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Image.network(
              "http://cdn.onlinewebfonts.com/svg/img_59062.png",
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: CustomText(text: "Email Address"),
          ),
          const SizedBox(
            height: 10,
          ),
          FormTextField(
              controller: email, suffixIcon: const Icon(Icons.email_outlined)),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: CustomText(text: "Password"),
          ),
          const SizedBox(
            height: 10,
          ),
          FormTextField(
              controller: password,
              isPass: true,
              suffixIcon: const Icon(Icons.visibility_outlined)),
          const SizedBox(
            height: 10,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: CustomText(
                  text: "Forgot password?",
                  color: Colors.black.withOpacity(0.6),
                ),
              )),
          const SizedBox(
            height: 40,
          ),
          Align(
              alignment: Alignment.center,
              child: CustomButton(
                  buttonColor: Colors.amber,
                  text: "login",
                  function: () async {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    User? loggedInUser;
                    try {
                      UserCredential userCredential =
                          await auth.signInWithEmailAndPassword(
                              email: email.text, password: password.text);
                      loggedInUser = userCredential.user;
                    } on FirebaseAuthException catch (e) {
                      Fluttertoast.showToast(msg: e.code.toString());
                    }
                    if (loggedInUser != null) {
                      pushScreen();
                    }
                  })),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  pushScreen() {
    KRoutes.push(context, const HomePage());
  }
}
