import 'package:flutter/material.dart';

class Textformfielddecorated extends StatelessWidget {
  const Textformfielddecorated({
    super.key,
    required this.text,
    required this.validator,
    required this.textEditingController,
    this.height = 50,
    this.width = 300,
  });
  final String text;
  final String? Function(String?)? validator;
  final TextEditingController textEditingController;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: Colors.cyan,
            border: Border.all(style: BorderStyle.none),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(81, 12, 12, 12).withOpacity(0.3),
                offset: Offset(1, 2),
                blurRadius: 2,
                spreadRadius: 2,
              )
            ]),
        child: TextFormField(
          controller: textEditingController,
          validator: validator,
          decoration: InputDecoration(counter: Offstage(), hintText: text),
        ),
      ),
    );
  }
}
