import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/Resources/fire_storage.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_app_bar.dart';
import 'package:restomation/Widgets/custom_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Scaffold(
        appBar: BaseAppBar(
            title: "Home",
            appBar: AppBar(),
            widgets: const [],
            appBarHeight: 50),
        body: Center(
            child: CustomButton(
                buttonColor: primaryColor,
                text: "Upload image",
                function: () async {
                  final image = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.custom,
                    allowedExtensions: [
                      "png",
                      "jpg",
                    ],
                  );
                  if (image != null) {
                    final fileBytes = image.files.single.bytes;
                    final fileName = image.files.single.name;
                    await storage.uploadFile(fileBytes!, fileName);
                  } else {
                    Fluttertoast.showToast(msg: "No file selected");
                  }
                })));
  }
}
