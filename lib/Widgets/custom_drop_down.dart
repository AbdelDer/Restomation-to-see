import 'package:flutter/material.dart';
import 'package:restomation/Utils/contants.dart';
import 'package:restomation/Widgets/custom_text.dart';

class ListDropDown extends StatefulWidget {
  const ListDropDown({
    Key? key,
  }) : super(key: key);

  @override
  State<ListDropDown> createState() => _ListDropDownState();
}

class _ListDropDownState extends State<ListDropDown> {
  @override
  void initState() {
    setState(() {
      selectedMenuOption = menuOptions[0];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: selectedMenuOption,
      underline: const CustomText(text: ""),
      items: menuOptions
          .map((value) => DropdownMenuItem(
                value: value,
                child: SizedBox(
                  width: 100.0, // for example
                  child: CustomText(
                    text: value,
                    textAlign: TextAlign.center,
                  ),
                ),
              ))
          .toList(),
      onChanged: (dynamic value) {
        setState(() {
          selectedMenuOption = value;
        });
      },
      // ...
    );
  }
}
