import 'package:flutter/material.dart';
import 'package:restomation/Widgets/custom_text.dart';

class ListDropDown extends StatefulWidget {
  final List dynamicList;
  final TextEditingController selectedValue;
  const ListDropDown({
    Key? key,
    required this.dynamicList,
    required this.selectedValue,
  }) : super(key: key);

  @override
  State<ListDropDown> createState() => _ListDropDownState();
}

class _ListDropDownState extends State<ListDropDown> {
  @override
  void initState() {
    setState(() {
      widget.selectedValue.text = widget.dynamicList[0];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: widget.selectedValue.text,
      underline: const CustomText(text: ""),
      items: widget.dynamicList
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
          widget.selectedValue.text = value;
        });
      },
      // ...
    );
  }
}
