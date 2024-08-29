import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tamil_app/constant/color.dart';

import '../../constant/common_text.dart';
import '../sign_in_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final emailAddressController = TextEditingController();
  final questionController = TextEditingController();
  final helpKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {},
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 20.h,
          ),
        ),
        title: CommonText(
          text: 'Ask a question',
          fontSize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Form(
          key: helpKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 89.h),
                TextFormField(
                  controller: emailAddressController,
                  validator: (value) {
                    RegExp regex1 = RegExp(
                        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                    if (value!.trim().isEmpty) {
                      return 'This field is required';
                    } else if (!regex1.hasMatch(value)) {
                      return 'please enter valid Email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Your email address*',
                    hintStyle: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    fillColor: Color(0xffF8EEF3),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.red)),
                  ),
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: questionController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter the question";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Your question*',
                    hintStyle: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    fillColor: Color(0xffF8EEF3),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.red)),
                  ),
                ),
                SizedBox(height: 109.h),
                Row(
                  children: [
                    button(
                      onPressed: () {
                        if (helpKey.currentState!.validate()) {
                          FirebaseFirestore.instance
                              .collection('email')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            'Question': questionController.text,
                          }).then((value) => Get.snackbar(
                                    'Thank you for submitting the question.',
                                    'Successful',
                                    backgroundColor: PickColor.buttonColor,
                                    colorText: Colors.white,
                                  ));
                        } else {
                          return null;
                        }
                      },
                      color: PickColor.buttonColor,
                      name: 'Submit',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      textColor: Colors.white,
                      colorSide: Colors.transparent,
                    ),
                    Spacer(),
                    TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.purpleAccent,
                        ),
                        onPressed: () {
                          emailAddressController.clear();
                          questionController.clear();
                        },
                        child: CommonText(
                          text: 'Clear form',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: PickColor.buttonColor,
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
