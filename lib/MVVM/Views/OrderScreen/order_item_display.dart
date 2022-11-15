import 'package:flutter/material.dart';

import '../../Repo/Storage Service/storage_service.dart';

class OrderItemDisplay extends StatelessWidget {
  final Map data;
  const OrderItemDisplay({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(builder: (context, AsyncSnapshot snapshot) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (orderList[index]["items"] as Map).length,
        itemBuilder: (context, itemIndex) {
          List foodItem = (orderList[index]["items"] as Map).values.toList();
          return orderItemDisplay(context, foodItem[itemIndex]);
        },
      );
    });
  }

  Widget orderItemDisplay(BuildContext context, Map data) {
    final ref = StorageService.storage.ref().child(data["image"]);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.adjust_rounded,
                color: Colors.green,
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
                "Quantity : ${data["quantity"]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          FutureBuilder(
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
              })
        ],
      ),
    );
  }
}
