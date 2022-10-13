import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils/contants.dart';

class CustomSearch extends StatelessWidget {
  final bool enabled;
  final TextEditingController? controller;
  final String? searchText;
  final dynamic function;
  final void Function(String)? onSubmitted;
  const CustomSearch(
      {Key? key,
      this.enabled = true,
      this.controller,
      this.function,
      this.searchText,
      this.onSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: primaryColor)),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.search,
            color: primaryColor,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            textInputAction: TextInputAction.go,
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
                hintText: searchText ?? "Search anything",
                border: InputBorder.none),
            onChanged: (value) async {
              await function();
            },
          ))
        ],
      ),
    );
  }
}
