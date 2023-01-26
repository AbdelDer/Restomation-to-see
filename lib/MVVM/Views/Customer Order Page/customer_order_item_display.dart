import 'package:beamer/beamer.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_text.dart';
import 'package:restomation/Widgets/custom_text_field.dart';

import '../../../Provider/cart_provider.dart';
import '../../../Utils/app_routes.dart';
import '../../../Widgets/custom_button.dart';
import '../../Repo/FCM Service/fcm_service.dart';

class CustomerOrderItemsView extends StatefulWidget {
  final String restaurantName;
  final String phone;
  final String tableKey;
  final String name;
  final String isTableClean;
  final Map order;
  const CustomerOrderItemsView(
      {super.key,
      required this.restaurantName,
      required this.phone,
      required this.tableKey,
      required this.name,
      required this.isTableClean,
      required this.order});

  @override
  State<CustomerOrderItemsView> createState() => _CustomerOrderItemsViewState();
}

class _CustomerOrderItemsViewState extends State<CustomerOrderItemsView> {
  final Razorpay _razorpay = Razorpay();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  TextEditingController controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Do something when payment succeeds
    await FirebaseDatabase.instance
        .ref()
        .child("orders")
        .child(widget.restaurantName)
        .child(widget.order["key"] ?? "")
        .remove();
    await FirebaseDatabase.instance
        .ref()
        .child("completed-orders")
        .child(widget.restaurantName)
        .child(formatter.format(DateTime.now()))
        .child(widget.order["phone"] ?? "")
        .push()
        .update({
      "name": widget.order["name"],
      "phone": widget.order["phone"],
      "table_name": widget.order["table_name"],
      "order_status": "completed",
      "isTableClean": widget.order["isTableClean"],
      "waiter": widget.order["waiter"],
      "hasNewItems": widget.order["hasNewItems"]
    }).then((value) {
      Fluttertoast.showToast(msg: "Payment successful");
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails

    Future.delayed(const Duration(milliseconds: 300), () {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          title: "Try Again",
          text: response.message.toString(),
          confirmBtnText: "ok",
          onConfirmBtnTap: () {
            Navigator.pop(context);
          });
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    if (kDebugMode) {
      print("External Wallet Mode");
      print("Wallet Name: ${response.walletName}");
    }
  }

  @override
  void dispose() {
    super.dispose();
    controllerEmail.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService.db
          .ref()
          .child("order_items")
          .child(widget.restaurantName)
          .child(widget.phone)
          .limitToLast(1)
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) =>
          orderItemView(context, snapshot),
    );
  }

  Widget orderItemView(
      BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
    FirebaseDatabase db = FirebaseDatabase.instance;
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (snapshot.hasError) {
      return const CustomText(
        text: "Error",
      );
    }
    if (snapshot.data!.snapshot.children.isEmpty) {
      return const Center(
        child: CustomText(text: "Order has been completed, please go back"),
      );
    }
    Map orderItems = snapshot.data!.snapshot.value as Map;
    List orderItemsKeys = orderItems.keys.toList();
    List items = orderItems[orderItemsKeys[0]];

    return Scaffold(
      backgroundColor: kBackground,
      floatingActionButton: (widget.order["waiter"] != "none")
          ? FloatingActionButton.extended(
              onPressed: () async {
                DatabaseEvent staff = await db
                    .ref("staff")
                    .orderByChild("name")
                    .equalTo(widget.order["waiter"])
                    .once();
                Map staffData = (staff.snapshot.value as Map);
                String staffKey = (staffData.keys.toList())[0];
                String token = staffData[staffKey]["token"];
                FCMServices.sendFCM(token, token, widget.order["table_name"],
                    "Go to the table quick !!");
              },
              label: Row(
                children: const [
                  Icon(Icons.notifications),
                  SizedBox(
                    width: 10,
                  ),
                  CustomText(
                    text: "Call waiter",
                    color: kWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ))
          : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButton(
                buttonColor: primaryColor,
                text: "Add more items",
                textColor: kWhite,
                function: () {
                  Beamer.of(context).beamToNamed(
                      "/restaurants-menu-category/${widget.restaurantName},${widget.tableKey},${widget.name},${widget.phone},${widget.isTableClean},yes,${orderItemsKeys[0]},${items.length}");
                }),
            // if (widget.order["order_status"].toString().toLowerCase() == "done")
            CustomButton(
                buttonColor: primaryColor,
                text: "Pay Now",
                textColor: kWhite,
                function: () async {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Redirecting to payment gateway");
                  await payment(widget.order["name"], widget.order["name"],
                      widget.order["phone"], getTotalPrice(items));
                })
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  text: "Total Bill",
                  fontWeight: FontWeight.bold,
                  fontsize: 20,
                  color: Colors.black87,
                ),
                const SizedBox(
                  width: 4,
                ),
                CustomText(
                  text: "₹${getTotalPrice(items)}",
                  fontsize: 20,
                  fontWeight: FontWeight.w900,
                  color: kblack,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, itemIndex) {
                  if (itemIndex == items.length - 1) {
                    return Column(
                      children: [
                        myOrderedItems(context, items[itemIndex]),
                        const SizedBox(height: 200)
                      ],
                    );
                  } else {
                    return myOrderedItems(context, items[itemIndex]);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget myOrderedItems(BuildContext context, Map data) {
    final size = MediaQuery.of(context).size;
    final ref = StorageService.storage.ref().child(data["image"]);
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       SizedBox(
    //         width: MediaQuery.of(context).size.width / 2 - 10,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Row(
    //               children: [
    //                 const Icon(
    //                   Icons.adjust_rounded,
    //                   color: Colors.green,
    //                 ),
    //                 const SizedBox(
    //                   width: 10,
    //                 ),
    //                 CustomText(
    //                   text: data["cookingStatus"],
    //                   color: data["cookingStatus"] == "pending"
    //                       ? Colors.red
    //                       : data["cookingStatus"] == "cooking"
    //                           ? primaryColor
    //                           : data["cookingStatus"] == "ready"
    //                               ? Colors.amber
    //                               : data["cookingStatus"] == "delivered"
    //                                   ? Colors.green
    //                                   : Colors.red,
    //                 )
    //               ],
    //             ),
    //             const SizedBox(
    //               height: 10,
    //             ),
    //             Text(
    //               data["name"],
    //               style: const TextStyle(fontWeight: FontWeight.bold),
    //             ),
    //             const SizedBox(
    //               height: 10,
    //             ),
    //             Text(
    //               "₹${data["price"]} x ${data["quantity"]} = ${(double.parse(data["price"]) * data["quantity"])}",
    //               style: const TextStyle(fontWeight: FontWeight.bold),
    //             ),
    //             const SizedBox(
    //               height: 10,
    //             ),
    //             Text(
    //               "${data["type"]}",
    //               style: TextStyle(
    //                 fontWeight: FontWeight.bold,
    //                 color: Colors.grey.shade600,
    //               ),
    //             ),
    //             const SizedBox(
    //               height: 10,
    //             ),
    //             CustomText(
    //               text: data["description"],
    //               color: Colors.grey.shade600,
    //             ),
    //           ],
    //         ),
    //       ),

    //     ],
    //   ),
    // );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder(
                  future: ref.getDownloadURL(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                  offset: Offset(0, 0),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  color: Colors.black12)
                            ],
                            image: DecorationImage(
                                image: NetworkImage(snapshot.data!),
                                fit: BoxFit.fill)),
                      );
                    }
                    return Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                              offset: Offset(0, 0),
                              spreadRadius: 2,
                              blurRadius: 2,
                              color: Colors.black12)
                        ],
                      ),
                    );
                  }),
              const SizedBox(width: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Image.network(
                      'https://img.icons8.com/small/16/000000/vegetarian-food-symbol.png',
                      color: data["type"].toString().toLowerCase() == "veg"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: '${data["name"]}',
                          maxLines: 2,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        CustomText(
                          text: data["description"],
                          color: Colors.black87,
                        ),
                        Row(
                          children: [
                            CustomText(
                              text:
                                  "₹${data["price"]} x ${data["quantity"]} = ",
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                            CustomText(
                              text:
                                  "₹${(double.parse(data["price"]) * data["quantity"])}",
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: data["cookingStatus"] == "pending"
                      ? kYellow
                      : data["cookingStatus"] == "cooking"
                          ? Colors.green.shade600
                          : data["cookingStatus"] == "ready"
                              ? kGreen
                              : data["cookingStatus"] == "delivered"
                                  ? kGreen
                                  : Colors.red,
                ),
                child: CustomText(
                  text: data["cookingStatus"],
                  color: Colors.white,
                  fontsize: 12,
                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future gettingPaymentDetails(
      BuildContext context, String name, String phone, String price) {
    final formKey = GlobalKey<FormState>();
    RegExp emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: formKey,
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        width: 100,
                        height: 100,
                        child: Image.asset("assets/splash.png")),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Please enter your detail',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FormTextField(
                      controller: controllerEmail,
                      suffixIcon: const Icon(Icons.email),
                      validator: (controllerEmail) {
                        if (controllerEmail!.isEmpty || controllerEmail == "") {
                          return "Please enter email";
                        } else if (!emailValid.hasMatch(controllerEmail)) {
                          return "Please write valid format";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        buttonColor: Colors.blue,
                        text: "Pay Now",
                        textColor: Colors.white,
                        function: () async {
                          if (formKey.currentState!.validate()) {
                            Fluttertoast.showToast(msg: "Pay Now Clicked");
                            await payment(name, controllerEmail.text.trim(),
                                phone, price);
                          }
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  payment(String name, String email, String phone, String amount) async {
    var options = {
      "key": "rzp_live_lYQbu0nR86sa1C",
      "amount": int.tryParse(amount)! * 100,
      "currency": "INR",
      "name": "Restomation",
      "description": "Test Transaction",
      "image": "assets/splash.png",
      // "order_id": "order_9A33XWu170gUtm",
      "callback_url": "https://eneqd3r9zrjok.x.pipedream.net/",
      "prefill": {
        "name": name.toString(),
        "email": email.toString(),
        "contact": phone.toString()
      },
      "theme": {"color": "#e1679c"}
    };

    _razorpay.open(options);
  }

  String getTotalPrice(List items) {
    double total = 0;
    for (var element in items) {
      if (element["cookingStatus"] != "cancelled") {
        total += double.parse(element["price"]) * element["quantity"];
      }
    }
    return total.toString();
  }
}
