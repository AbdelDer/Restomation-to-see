import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/Widgets/custom_button.dart';
import 'package:restomation/Widgets/custom_drop_down.dart';
import 'package:restomation/Widgets/custom_loader.dart';

import '../../../Utils/app_routes.dart';
import '../../../Utils/contants.dart';
import '../../../Widgets/custom_alert.dart';
import '../../../Widgets/custom_app_bar.dart';
import '../../../Widgets/custom_search.dart';
import '../../../Widgets/custom_text.dart';
import '../../../Widgets/custom_text_field.dart';
import '../../Repo/Database Service/database_service.dart';
import '../../Repo/Storage Service/storage_service.dart';

class StaffPage extends StatefulWidget {
  final String restaurantsKey;

  const StaffPage({
    super.key,
    required this.restaurantsKey,
  });

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final TextEditingController personNameController = TextEditingController();
  final TextEditingController personPhoneController = TextEditingController();
  final TextEditingController personEmailController = TextEditingController();
  final TextEditingController personAddressController = TextEditingController();
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "",
        appBar: AppBar(),
        widgets: const [],
        appBarHeight: 50,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showCustomDialog(context);
          },
          label: const CustomText(
            text: "Create Staff",
            color: Colors.white,
          )),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "Staff :",
                    fontsize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomSearch(
                    controller: controller,
                    searchText: "Search staff",
                    function: () {
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: StreamBuilder(
                        stream: FirebaseDatabase.instance
                            .ref()
                            .child("restaurants")
                            .child(widget.restaurantsKey)
                            .child("staff")
                            .onValue,
                        builder:
                            (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                          return staffView(snapshot);
                        }),
                  ),
                ],
              ))),
    );
  }

  Widget staffView(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CustomLoader();
    }
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CustomText(text: "Something went wrong")],
        ),
      );
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [CustomText(text: "No staff added Yet !!")],
        ),
      );
    }
    Map allStaff = snapshot.data!.snapshot.value as Map;
    List staffList = allStaff.keys.toList();
    final suggestions = allStaff.keys.toList().where((element) {
      final categoryTitle = allStaff[element]["name"].toString().toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    staffList = suggestions;
    return Column(
      children: staffList.map((e) {
        Map person = allStaff[e] as Map;
        person["key"] = e;
        final ref = StorageService.storage.ref().child(person["image"]);
        return Slidable(
          endActionPane: _actionPane(person),
          child: ListTile(
            leading: FutureBuilder(
                future: ref.getDownloadURL(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CircleAvatar(
                      backgroundColor: kWhite,
                      foregroundImage: NetworkImage(snapshot.data!),
                    );
                  }
                  return const CircleAvatar(
                    backgroundColor: kWhite,
                    child: CircularProgressIndicator.adaptive(),
                  );
                }),
            title: Text(
              person["name"],
            ),
            subtitle: Text(person["role"]),
            trailing: const Icon(Icons.person_outline),
          ),
        );
      }).toList(),
    );
  }

  void showCustomDialog(BuildContext context,
      {bool update = false, Map? person}) {
    FilePickerResult? image;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, refreshState) {
            return AlertDialog(
              scrollable: true,
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(text: "Upload Image"),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                        onTap: () async {
                          image = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            allowedExtensions: [
                              "png",
                              "jpg",
                            ],
                          );
                          if (image == null) {
                            Fluttertoast.showToast(msg: "No file selected");
                          } else {
                            refreshState(() {});
                          }
                        },
                        child: image != null
                            ? CircleAvatar(
                                radius: 100,
                                backgroundColor: kWhite,
                                foregroundImage:
                                    MemoryImage(image!.files.single.bytes!),
                              )
                            : const CircleAvatar(
                                radius: 100,
                                backgroundColor: kWhite,
                                foregroundImage: NetworkImage(
                                    "https://media.istockphoto.com/vectors/cartoon-image-people-avatar-profile-flat-vector-social-media-photo-vector-id1339903732?k=20&m=1339903732&s=612x612&w=0&h=hHtK0ro8X1vLOxUAuHX_AUcbjyTylR9-9Q0OjgJm16E="),
                              )),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "Person's name"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: personNameController,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "Person's phone"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: personPhoneController,
                      keyboardtype: TextInputType.number,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "Person's email"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: personEmailController,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "Person's address"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: personAddressController,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const ListDropDown(),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        buttonColor: primaryColor,
                        text: update ? "Update" : "create",
                        textColor: kWhite,
                        function: () async {
                          if (image == null ||
                              personNameController.text.isEmpty ||
                              personPhoneController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg:
                                    "Make sure to fill all fields and upload an image of the item");
                          } else {
                            final fileBytes = image!.files.single.bytes;
                            final fileName = image!.files.single.name;
                            if (update) {
                              Map item = {
                                "name": personNameController.text,
                                "phoneNo": personPhoneController.text,
                                "image":
                                    "restaurants/${widget.restaurantsKey}/staff/$fileName",
                                "email": personEmailController.text,
                                "address": personAddressController.text,
                                "role": selectedRole,
                              };
                              Alerts.customLoadingAlert(context);
                              await DatabaseService.updateStaffCategoryPerson(
                                      widget.restaurantsKey,
                                      person!["key"],
                                      person["image"],
                                      fileName,
                                      item,
                                      fileBytes!)
                                  .then((value) {
                                personNameController.clear();
                                personPhoneController.clear();
                                personEmailController.clear();
                                personAddressController.clear();
                                KRoutes.pop(context);
                                return KRoutes.pop(context);
                              });
                            } else {
                              Map item = {
                                "name": personNameController.text,
                                "phoneNo": personPhoneController.text,
                                "image":
                                    "restaurants/${widget.restaurantsKey}/staff/$fileName",
                                "email": personEmailController.text,
                                "address": personAddressController.text,
                                "role": selectedRole,
                              };
                              Alerts.customLoadingAlert(context);
                              await DatabaseService.createStaffCategoryPerson(
                                      widget.restaurantsKey,
                                      fileName,
                                      item,
                                      fileBytes!)
                                  .then((value) {
                                personNameController.clear();
                                personPhoneController.clear();
                                personEmailController.clear();
                                personAddressController.clear();
                                KRoutes.pop(context);
                                return KRoutes.pop(context);
                              });
                            }
                          }
                        }),
                  ],
                ),
              ),
            );
          });
        });
  }

  ActionPane _actionPane(
    Map person,
  ) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          onPressed: (context) {
            personNameController.text = person["name"];
            personPhoneController.text = person["phoneNo"];
            personEmailController.text = person["email"];
            personAddressController.text = person["address"];
            showCustomDialog(context, update: true, person: person);
          },
          backgroundColor: const Color(0xFF21B7CA),
          foregroundColor: Colors.white,
          icon: Icons.share,
          label: 'Edit',
        ),
        SlidableAction(
          onPressed: (context) {
            Alerts.customLoadingAlert(context);
            DatabaseService.storage.ref().child(person["image"]).delete();
            DatabaseService.db
                .ref()
                .child("restaurants")
                .child(widget.restaurantsKey)
                .child("staff")
                .child(person["key"])
                .remove();
            KRoutes.pop(context);
          },
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ],
    );
  }

  @override
  void dispose() {
    personNameController.dispose();
    personPhoneController.dispose();
    personEmailController.dispose();
    personAddressController.dispose();
    controller.dispose();
    super.dispose();
  }
}
