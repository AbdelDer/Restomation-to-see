import 'package:beamer/beamer.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:restomation/MVVM/Repo/Database%20Service/database_service.dart';
import 'package:restomation/MVVM/Repo/Storage%20Service/storage_service.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_text.dart';

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

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    if (kDebugMode) {
      print("Success Mode");
      print("Payement ID: ${response.paymentId}");
      Fluttertoast.showToast(msg: "Payment was a Success");
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 300), () {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            title: "Done",
            text: "Payment was successfully transferred",
            confirmBtnText: "OKAY",
            onConfirmBtnTap: () {
              Navigator.pop(context);
            });
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    if (kDebugMode) {
      print("Failure Mode");
      print("Failure Code: ${response.code}");
      print("Message: ${response.message}");
      Fluttertoast.showToast(msg: response.message.toString());
      Future.delayed(const Duration(milliseconds: 300), () {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            title: "Try Again",
            text: "Payment was Failed to transfer",
            confirmBtnText: "OKAY",
            onConfirmBtnTap: () {
              Navigator.pop(context);
            });
      });
    }
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
        child: CustomText(text: "No Orders Yet !!"),
      );
    }
    Map orderItems = snapshot.data!.snapshot.value as Map;
    List orderItemsKeys = orderItems.keys.toList();
    List items = orderItems[orderItemsKeys[0]];

    return Scaffold(
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
                text: "Pay",
                textColor: kWhite,
                function: () {
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.confirm,
                    width: 300,
                    title: "",
                    text: "Please go to the counter to pay",

                    // onConfirmBtnTap: () async {
                    //   Navigator.pop(context);
                    //   Fluttertoast.showToast(msg: "Pay Now Clicked");
                    //   await payment(
                    //       widget.order["name"],
                    //       widget.order["name"],
                    //       widget.order["phone"],
                    //       getTotalPrice(items));
                    // }
                  );
                })
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: "Total Bill",
                fontWeight: FontWeight.bold,
                fontsize: 20,
              ),
              CustomText(
                text: getTotalPrice(items),
                fontsize: 20,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            thickness: 1,
            indent: 100,
            endIndent: 100,
            color: kblack,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, itemIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: myOrderedItems(context, items[itemIndex]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget myOrderedItems(BuildContext context, Map data) {
    final ref = StorageService.storage.ref().child(data["image"]);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.adjust_rounded,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  CustomText(
                    text: data["cookingStatus"],
                    color: data["cookingStatus"] == "pending"
                        ? Colors.red
                        : data["cookingStatus"] == "cooking"
                            ? primaryColor
                            : data["cookingStatus"] == "ready"
                                ? Colors.amber
                                : data["cookingStatus"] == "delivered"
                                    ? Colors.green
                                    : Colors.red,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                data["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Rs. ${data["price"]} x ${data["quantity"]} = ${(double.parse(data["price"]) * data["quantity"])}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "${data["type"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                text: data["description"],
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: FutureBuilder(
              future: ref.getDownloadURL(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    width: 170,
                    height: 150,
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
                            fit: BoxFit.cover)),
                  );
                }
                return Container(
                  width: 170,
                  height: 150,
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
        )
      ],
    );
  }

  payment(String name, String email, String phone, String amount) async {
    var options = {
      "key":
          "rzp_test_XYujmoenCLI42U", // Enter the Key ID generated from the Dashboard
      "amount": int.tryParse(amount)! *
          100, // Amount is in currency subunits. Default currency is INR. Hence, 50000 refers to 50000 paise
      "currency": "INR",
      "name": "Restomation",
      "description": "Test Transaction",
      "image": "assets/splash.png",
      // "order_id": "order_9A33XWu170gUtm", //This is a sample Order ID. Pass the `id` obtained in the response of Step 1
      "callback_url": "https://eneqd3r9zrjok.x.pipedream.net/",
      "prefill": {
        "name": name.toString(),
        "email": email.toString(),
        "contact": phone.toString()
      },
      // "notes": {
      //   "address": "Razorpay Corporate Office"
      // },
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
