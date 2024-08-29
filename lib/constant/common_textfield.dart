import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tamil_app/constant/color.dart';

class CommonTextField extends StatelessWidget {
  CommonTextField(
      {Key? key,
      required this.hintText,
      required this.controller,
      this.validator,
      this.onTap,
      required this.obscureText,
      this.suffixIcon})
      : super(key: key);

  final String hintText;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final GestureTapCallback? onTap;
  final dynamic obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      textInputAction: TextInputAction.next,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
          filled: true,
          suffixIcon: suffixIcon,
          fillColor: Colors.white,
          hintStyle: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
          hintText: hintText,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(color: PickColor.buttonColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(color: PickColor.buttonColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(color: Colors.red),
          )),
    );
  }
}
