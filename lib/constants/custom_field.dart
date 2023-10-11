import 'package:beacon_project/constants/themes.dart';
import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  const CustomField({super.key, required this.label, required this.control, required this.obs, required this.hint});
  final String label;
  final String hint;
  final TextEditingController control;
  final bool obs;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      controller: control,
      obscureText: obs,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
              color: Color(0xFF979797),
              style: BorderStyle.solid
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF979797),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: CustomColors.circleColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
