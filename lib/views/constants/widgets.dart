import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  const TextInputField(
      {Key? key,
      required this.hint,
      this.inputType,
      this.inputAction,
      required this.controller,
      required this.isPasswordfield})
      : super(key: key);

  final String hint;
  final TextInputType? inputType;
  final TextInputAction? inputAction;
  final bool isPasswordfield;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        height: size.height * 0.08,
        width: size.width * 0.8,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Color(0xFFf6f7fb),
          border: Border.all(color: Color(0xFFcbcbcb)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: TextField(
            obscureText: isPasswordfield,
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            style: TextStyle(fontSize: 20),
            keyboardType: inputType,
            textInputAction: inputAction,
          ),
        ),
      ),
    );
  }
}
