import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restomation/Widgets/custom_button.dart';

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
  final String resturantKey;
  final String resturantName;
  final String staffCategoryKey;
  final String staffCategoryName;
  const StaffPage(
      {super.key,
      required this.resturantKey,
      required this.resturantName,
      required this.staffCategoryKey,
      required this.staffCategoryName});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final TextEditingController personNameController = TextEditingController();
  final TextEditingController personPhoneController = TextEditingController();
  final TextEditingController personCnicController = TextEditingController();
  final TextEditingController personAddressController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  Map allsingleResturantsStaffCategories = {};
  @override
  void initState() {
    getsingleResturantsStaffCategories();
    super.initState();
  }

  getsingleResturantsStaffCategories() {
    DatabaseReference ordersCountRef = FirebaseDatabase.instance
        .ref()
        .child("resturants")
        .child(widget.resturantKey)
        .child("staff")
        .child(widget.staffCategoryKey)
        .child(widget.staffCategoryName);
    ordersCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      data as Map?;
      setState(() {
        if (data != null) {
          allsingleResturantsStaffCategories = data;
        }
      });
    });
  }

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
          child:
              Padding(padding: const EdgeInsets.all(20), child: staffView())),
    );
  }

  Widget staffView() {
    if (allsingleResturantsStaffCategories.keys.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(text: "No ${widget.staffCategoryName} staff added Yet !!")
        ],
      );
    }
    List singleCategoryStaffList =
        allsingleResturantsStaffCategories.keys.toList();
    final suggestions =
        allsingleResturantsStaffCategories.keys.toList().where((element) {
      final categoryTitle = allsingleResturantsStaffCategories[element]["name"]
          .toString()
          .toLowerCase();
      final input = controller.text.toLowerCase();
      return categoryTitle.contains(input);
    }).toList();
    singleCategoryStaffList = suggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "${widget.staffCategoryName} :",
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
        Column(
          children: singleCategoryStaffList.map((e) {
            Map person = allsingleResturantsStaffCategories[e] as Map;
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
                title: CustomText(
                  text: person["name"],
                  fontsize: 20,
                ),
                isThreeLine: true,
                subtitle: CustomText(text: person["cnic"]),
                trailing: const Icon(Icons.person_outline),
              ),
            );
          }).toList(),
        )
      ],
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
                    const CustomText(text: "Person's cnic"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: personCnicController,
                      keyboardtype: TextInputType.number,
                      suffixIcon: const Icon(Icons.shower_sharp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomText(text: "Person's phone no"),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: personPhoneController,
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
                      height: 20,
                    ),
                    CustomButton(
                        buttonColor: primaryColor,
                        text: update ? "Update" : "create",
                        textColor: kWhite,
                        function: () async {
                          if (image == null ||
                              personNameController.text.isEmpty ||
                              personPhoneController.text.isEmpty ||
                              personCnicController.text.isEmpty ||
                              personAddressController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg:
                                    "Make sure to fill all fields and upload an image of the item");
                          } else {
                            final fileBytes = image!.files.single.bytes;
                            final fileName = image!.files.single.name;
                            if (update) {
                              Map item = {
                                "name": personNameController.text,
                                "cnic": personCnicController.text,
                                "image":
                                    "resturants/${widget.resturantName}/staff/${widget.staffCategoryName}/$fileName",
                                "phoneNo": personPhoneController.text,
                                "address": personAddressController.text
                              };
                              Alerts.customLoadingAlert(context);
                              await DatabaseService.updateStaffCategoryPerson(
                                      widget.resturantKey,
                                      widget.staffCategoryKey,
                                      person!["key"],
                                      widget.resturantName,
                                      widget.staffCategoryName,
                                      person["image"],
                                      fileName,
                                      item,
                                      fileBytes!)
                                  .then((value) {
                                personNameController.clear();
                                personNameController.clear();
                                personCnicController.clear();
                                personAddressController.clear();
                                KRoutes.pop(context);
                                return KRoutes.pop(context);
                              });
                            } else {
                              Map item = {
                                "name": personNameController.text,
                                "cnic": personCnicController.text,
                                "image":
                                    "resturants/${widget.resturantName}/staff/${widget.staffCategoryName}/$fileName",
                                "phoneNo": personPhoneController.text,
                                "address": personAddressController.text
                              };
                              Alerts.customLoadingAlert(context);
                              await DatabaseService.createStaffCategoryPerson(
                                      widget.resturantKey,
                                      widget.resturantName,
                                      widget.staffCategoryKey,
                                      widget.staffCategoryName,
                                      fileName,
                                      item,
                                      fileBytes!)
                                  .then((value) {
                                personNameController.clear();
                                personPhoneController.clear();
                                personCnicController.clear();
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
            personCnicController.text = person["cnic"];
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
                .child("resturants")
                .child(widget.resturantKey)
                .child("staff")
                .child(widget.staffCategoryKey)
                .child(widget.staffCategoryName)
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
    personCnicController.dispose();
    personAddressController.dispose();
    controller.dispose();
    super.dispose();
  }
}
