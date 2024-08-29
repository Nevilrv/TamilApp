import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:tamil_app/Auth/google_signIn_service.dart';
import 'package:tamil_app/constant/color.dart';
import 'package:tamil_app/constant/common_text.dart';
import 'package:tamil_app/constant/common_textfield.dart';
import 'package:tamil_app/constant/textname.dart';
import 'package:tamil_app/controller/network_checker.dart';
import 'package:tamil_app/views/bottom_navigation_bar_screen.dart';
import 'package:tamil_app/views/onBoarding_screen.dart';

import '../Auth/sign_in_Services.dart';
import '../notification/utils.dart';
import 'forget_password_screen.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final passWordController = TextEditingController();
  final emailData = TextEditingController();
  bool isPassword = false;

  final key = GlobalKey<FormState>();
  final key1 = GlobalKey<FormState>();
  bool isEmailValid(String email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern.toString());
    return regex.hasMatch(email);
  }

  bool bottom = false;
  bool isGoogleLoading = false;
  bool loader = false;
  bool loader1 = false;

  List<String> emailList = [];

  void getUserData() async {
    print('GET DATA');

    QuerySnapshot<Map<String, dynamic>> data =
        await FirebaseFirestore.instance.collection('email').get();

    data.docs.forEach((element) {
      emailList.add(element.data()['emails']);
    });
  }

  ConnectivityProvider _connectivityProvider = Get.put(ConnectivityProvider());

  @override
  void initState() {
    _connectivityProvider.startMonitoring();
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: false,
      body: GetBuilder<ConnectivityProvider>(
        builder: (controller) {
          if (controller.isOnline!) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => OnBoardingScreen());
                        },
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 20.h,
                        ),
                      ),
                      SizedBox(height: 82.h),
                      Center(
                        child: SvgPicture.asset(
                          'assets/images/svg/sign.svg',
                          height: 346.h,
                          width: 363.w,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      Center(
                        child: CommonText(
                          text: TextName.signIn1,
                          textAlign: TextAlign.center,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 21.h),
                      Center(
                        child: CommonText(
                          text: TextName.signIn2,
                          textAlign: TextAlign.center,
                          fontSize: 16.sp,
                          color: PickColor.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 37.h),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            isGoogleLoading = true;
                          });
                          if (isGoogleLoading == true) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: Get.height,
                                    width: Get.width,
                                    color: Colors.black12,
                                    child: Center(
                                      child: LoadingAnimationWidget.inkDrop(
                                        color: PickColor.buttonColor,
                                        size: 50.h,
                                      ),
                                    ),
                                  );
                                });
                            googleServices().then((value) {
                              GetStorage().write('google', email);
                              FirebaseFirestore.instance
                                  .collection('email')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .set(
                                {
                                  'emails': email,
                                  'payment': false,
                                  'createdAt': DateTime.now(),
                                  'plan': 0,
                                },
                              );
                              Get.to(() => BottomNavigationBarScreen());
                              setState(() {
                                isGoogleLoading = false;
                              });
                            });
                          }
                        },
                        height: 62.h,
                        minWidth: Get.width,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: BorderSide(color: PickColor.buttonColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg/google.svg',
                              height: 26.h,
                              width: 26.w,
                            ),
                            SizedBox(width: 14.w),
                            CommonText(
                              text: 'Sign in with Google',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: PickColor.buttonColor,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      MaterialButton(
                        onPressed: () {
                          Future.delayed(Duration.zero, () {
                            showModalBottomSheet(
                              isDismissible: false,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      void Function(void Function()) setState) {
                                    return Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: Container(
                                        height: 330.h,
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                        margin: EdgeInsets.only(
                                          bottom: 40.h,
                                          left: 20.w,
                                          right: 20.w,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w),
                                          child: Form(
                                            key: key1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 45.h),
                                                CommonText(
                                                  text: 'Sign in with email',
                                                  textAlign: TextAlign.center,
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                SizedBox(height: 30.h),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      bottom == true
                                                          ? BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              offset:
                                                                  Offset(0, 0),
                                                              spreadRadius: 0,
                                                              blurRadius: 0,
                                                            )
                                                          : BoxShadow(
                                                              color: Colors.grey
                                                                  .shade400,
                                                              offset: Offset(
                                                                  0, 1.8),
                                                              spreadRadius: 1.5,
                                                              blurRadius: 3),
                                                    ],
                                                  ),
                                                  child: CommonTextField(
                                                    validator: (value) {
                                                      RegExp regex1 = RegExp(
                                                          r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                                                      if (value!
                                                          .trim()
                                                          .isEmpty) {
                                                        setState(() {
                                                          bottom = true;
                                                        });
                                                        return 'This field is required';
                                                      } else if (!regex1
                                                          .hasMatch(value)) {
                                                        return 'please enter valid Email';
                                                      }
                                                      return null;
                                                    },
                                                    hintText: 'Email',
                                                    controller: emailController,
                                                    obscureText: false,
                                                  ),
                                                ),
                                                SizedBox(height: 35.h),
                                                Row(
                                                  children: [
                                                    button(
                                                      onPressed: () {
                                                        bottom = false;
                                                        Get.back();
                                                      },
                                                      colorSide:
                                                          PickColor.buttonColor,
                                                      name: 'Cancel',
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      textColor:
                                                          PickColor.buttonColor,
                                                    ),
                                                    Spacer(),
                                                    button(
                                                      onPressed: () async {
                                                        if (key1.currentState!
                                                            .validate()) {
                                                          bottom = false;

                                                          bool isLogin = false;

                                                          log('ALREADY ${emailList.contains(emailController.text)}');

                                                          isLogin = emailList
                                                              .contains(
                                                                  emailController
                                                                      .text);

                                                          Future.delayed(
                                                              Duration.zero,
                                                              () {
                                                            showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              isDismissible:
                                                                  false,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return StatefulBuilder(
                                                                  builder: (BuildContext
                                                                          context,
                                                                      void Function(
                                                                              void Function())
                                                                          setState) {
                                                                    return Padding(
                                                                      padding: MediaQuery.of(
                                                                              context)
                                                                          .viewInsets,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            610.h,
                                                                        width: Get
                                                                            .width,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            borderRadius: BorderRadius.circular(10.r)),
                                                                        margin: EdgeInsets.only(
                                                                            bottom:
                                                                                49.h,
                                                                            right: 20.w,
                                                                            left: 20.w),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 16.w),
                                                                          child:
                                                                              Form(
                                                                            key:
                                                                                key,
                                                                            child:
                                                                                SingleChildScrollView(
                                                                              physics: BouncingScrollPhysics(),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  SizedBox(height: 45.h),
                                                                                  CommonText(
                                                                                    text: isLogin ? 'Sign In' : 'Create account',
                                                                                    textAlign: TextAlign.center,
                                                                                    fontSize: 20.sp,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                  SizedBox(height: 30.h),
                                                                                  Container(
                                                                                    decoration: BoxDecoration(
                                                                                      boxShadow: [
                                                                                        bottom == true
                                                                                            ? BoxShadow(
                                                                                                color: Colors.white,
                                                                                                offset: Offset(0, 0),
                                                                                                spreadRadius: 0,
                                                                                                blurRadius: 0,
                                                                                              )
                                                                                            : BoxShadow(color: Colors.grey.shade400, offset: Offset(0, 1.8), spreadRadius: 1.5, blurRadius: 3),
                                                                                      ],
                                                                                    ),
                                                                                    child: CommonTextField(
                                                                                      validator: (value) {
                                                                                        RegExp regex1 = RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                                                                                        if (value!.trim().isEmpty) {
                                                                                          setState(() {
                                                                                            bottom = true;
                                                                                          });
                                                                                          return 'This field is required';
                                                                                        } else if (!regex1.hasMatch(value)) {
                                                                                          return 'please enter valid Email';
                                                                                        }
                                                                                        return null;
                                                                                      },
                                                                                      hintText: 'Email',
                                                                                      controller: emailController,
                                                                                      obscureText: false,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 17.h),
                                                                                  isLogin
                                                                                      ? Text('')
                                                                                      : Container(
                                                                                          decoration: BoxDecoration(
                                                                                            boxShadow: [
                                                                                              bottom == true
                                                                                                  ? BoxShadow(
                                                                                                      color: Colors.white,
                                                                                                      offset: Offset(0, 0),
                                                                                                      spreadRadius: 0,
                                                                                                      blurRadius: 0,
                                                                                                    )
                                                                                                  : BoxShadow(color: Colors.grey.shade400, offset: Offset(0, 1.8), spreadRadius: 1.5, blurRadius: 3),
                                                                                            ],
                                                                                          ),
                                                                                          child: CommonTextField(
                                                                                            obscureText: false,
                                                                                            validator: (value) {
                                                                                              setState(() {
                                                                                                bottom = true;
                                                                                              });
                                                                                              if (value!.trim().isEmpty) {
                                                                                                return 'This field is required';
                                                                                              } else if (!RegExp('[a-zA-Z]').hasMatch(value)) {
                                                                                                return 'please enter valid name';
                                                                                              }
                                                                                              return null;
                                                                                            },
                                                                                            hintText: 'First & last name',
                                                                                            controller: firstNameController,
                                                                                          ),
                                                                                        ),
                                                                                  SizedBox(height: 17.h),
                                                                                  Container(
                                                                                    decoration: BoxDecoration(
                                                                                      boxShadow: [
                                                                                        bottom == true
                                                                                            ? BoxShadow(
                                                                                                color: Colors.white,
                                                                                                offset: Offset(0, 0),
                                                                                                spreadRadius: 0,
                                                                                                blurRadius: 0,
                                                                                              )
                                                                                            : BoxShadow(color: Colors.grey.shade400, offset: Offset(0, 1.8), spreadRadius: 1.5, blurRadius: 3),
                                                                                      ],
                                                                                    ),
                                                                                    child: CommonTextField(
                                                                                      obscureText: !isPassword,
                                                                                      suffixIcon: GestureDetector(
                                                                                          child: isPassword ? Icon(Icons.visibility, color: PickColor.buttonColor) : Icon(Icons.visibility_off, color: PickColor.buttonColor),
                                                                                          onTap: () {
                                                                                            setState(() {
                                                                                              isPassword = !isPassword;
                                                                                              print(isPassword);
                                                                                            });
                                                                                          }),
                                                                                      validator: (password) {
                                                                                        RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                                                                                        if (password!.isEmpty) {
                                                                                          setState(() {
                                                                                            bottom = true;
                                                                                          });
                                                                                          return 'Password must be Formatted';
                                                                                        } else if (!regex.hasMatch(password)) {
                                                                                          return 'Password must be Formatted';
                                                                                        }
                                                                                        return null;
                                                                                      },
                                                                                      hintText: 'Password',
                                                                                      controller: passWordController,
                                                                                    ),
                                                                                  ),
                                                                                  Align(
                                                                                    alignment: Alignment.topRight,
                                                                                    child: TextButton(
                                                                                      onPressed: () {
                                                                                        Get.to(() => ForgetPasswordScreen());
                                                                                      },
                                                                                      child: Text(
                                                                                        'Reset Password?',
                                                                                        style: TextStyle(
                                                                                          color: PickColor.buttonColor,
                                                                                          fontSize: 20.sp,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Center(
                                                                                    child: CommonText(
                                                                                      text: 'By tapping save, you are indicating that you',
                                                                                      fontSize: 14.sp,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      color: PickColor.secondary1TextColor,
                                                                                    ),
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      CommonText(
                                                                                        text: 'agree to the',
                                                                                        fontSize: 14.sp,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: PickColor.secondary1TextColor,
                                                                                      ),
                                                                                      InkWell(
                                                                                        onTap: () {
                                                                                          print('terms');
                                                                                        },
                                                                                        child: CommonText(
                                                                                          text: 'Terms or Services',
                                                                                          fontSize: 14.sp,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          color: PickColor.buttonColor,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(height: 20.h),
                                                                                  Row(
                                                                                    children: [
                                                                                      button(
                                                                                        onPressed: () {
                                                                                          bottom = false;
                                                                                          Get.back();
                                                                                        },
                                                                                        colorSide: PickColor.buttonColor,
                                                                                        name: 'Cancel',
                                                                                        fontSize: 20.sp,
                                                                                        fontWeight: FontWeight.w700,
                                                                                        textColor: PickColor.buttonColor,
                                                                                      ),
                                                                                      Spacer(),
                                                                                      isLogin
                                                                                          ? button(
                                                                                              onPressed: () async {
                                                                                                if (key.currentState!.validate()) {
                                                                                                  log('signIn');
                                                                                                  setState(() {
                                                                                                    loader = true;
                                                                                                  });
                                                                                                  bottom = false;
                                                                                                  if (loader == true) {
                                                                                                    showDialog(
                                                                                                        context: context,
                                                                                                        builder: (BuildContext context) {
                                                                                                          return Container(
                                                                                                            height: Get.height,
                                                                                                            width: Get.width,
                                                                                                            color: Colors.black12,
                                                                                                            child: Center(
                                                                                                              child: LoadingAnimationWidget.inkDrop(
                                                                                                                color: PickColor.buttonColor,
                                                                                                                size: 50.h,
                                                                                                              ),
                                                                                                            ),
                                                                                                          );
                                                                                                        });
                                                                                                    bool? status = await EmailAuth.emailLogIn(emailController.text, passWordController.text);
                                                                                                    if (status == true) {
                                                                                                      GetStorage()
                                                                                                          .write('email', emailController.text)
                                                                                                          .then((value) => Get.snackbar(
                                                                                                                'signIn',
                                                                                                                'Successful',
                                                                                                                backgroundColor: PickColor.buttonColor,
                                                                                                                colorText: Colors.white,
                                                                                                              ))
                                                                                                          .whenComplete(
                                                                                                            () => Get.off(
                                                                                                              () => BottomNavigationBarScreen(),
                                                                                                            ),
                                                                                                          );
                                                                                                    }
                                                                                                  }
                                                                                                  // Get.to(() => BottomNavigationBarScreen());
                                                                                                  // emailController.clear();
                                                                                                  // passWordController.clear();
                                                                                                  // firstNameController.clear();
                                                                                                } else {
                                                                                                  setState(() {
                                                                                                    loader = false;
                                                                                                  });
                                                                                                  return null;
                                                                                                }
                                                                                              },
                                                                                              color: PickColor.buttonColor,
                                                                                              name: 'Next',
                                                                                              fontSize: 20.sp,
                                                                                              fontWeight: FontWeight.w700,
                                                                                              textColor: Colors.white,
                                                                                              colorSide: Colors.transparent,
                                                                                            )
                                                                                          : button(
                                                                                              onPressed: () async {
                                                                                                log('signUp');
                                                                                                if (key.currentState!.validate()) {
                                                                                                  setState(() {
                                                                                                    loader1 = true;
                                                                                                  });
                                                                                                  bottom = false;

                                                                                                  if (loader1 == true) {
                                                                                                    showDialog(
                                                                                                        context: context,
                                                                                                        builder: (BuildContext context) {
                                                                                                          return Container(
                                                                                                            height: Get.height,
                                                                                                            width: Get.width,
                                                                                                            color: Colors.black12,
                                                                                                            child: Center(
                                                                                                              child: LoadingAnimationWidget.inkDrop(
                                                                                                                color: PickColor.buttonColor,
                                                                                                                size: 50.h,
                                                                                                              ),
                                                                                                            ),
                                                                                                          );
                                                                                                        });

                                                                                                    bool? status = await EmailAuth.emailSignUp(emailController.text, passWordController.text);
                                                                                                    if (status == true) {
                                                                                                      GetStorage().write('email', emailController.text);
                                                                                                      FirebaseFirestore.instance
                                                                                                          .collection('email')
                                                                                                          .doc(FirebaseAuth.instance.currentUser?.uid)
                                                                                                          .set(
                                                                                                            {
                                                                                                              'emails': emailController.text,
                                                                                                              'payment': false,
                                                                                                              'password': passWordController.text,
                                                                                                              'firstName': firstNameController.text,
                                                                                                              'createdAt': DateTime.now(),
                                                                                                              'plan': 0,
                                                                                                              'fcmToken': storage.read('fcm'),
                                                                                                            },
                                                                                                          )
                                                                                                          .then((value) => Get.snackbar(
                                                                                                                'signUp',
                                                                                                                'Successful',
                                                                                                                backgroundColor: PickColor.buttonColor,
                                                                                                                colorText: Colors.white,
                                                                                                              ))
                                                                                                          .whenComplete(
                                                                                                            () => Get.off(
                                                                                                              () => BottomNavigationBarScreen(),
                                                                                                            ),
                                                                                                          );
                                                                                                    }
                                                                                                  }

                                                                                                  // Get.to(() => BottomNavigationBarScreen());
                                                                                                  // emailController.clear();
                                                                                                  passWordController.clear();
                                                                                                  firstNameController.clear();
                                                                                                } else {
                                                                                                  setState(() {
                                                                                                    loader1 = false;
                                                                                                  });
                                                                                                  return null;
                                                                                                }
                                                                                              },
                                                                                              color: PickColor.buttonColor,
                                                                                              name: 'Next',
                                                                                              fontSize: 20.sp,
                                                                                              fontWeight: FontWeight.w700,
                                                                                              textColor: Colors.white,
                                                                                              colorSide: Colors.transparent,
                                                                                            ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          });

                                                          // emailController.clear();
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      color:
                                                          PickColor.buttonColor,
                                                      name: 'Next',
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      textColor: Colors.white,
                                                      colorSide:
                                                          Colors.transparent,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          });
                        },
                        height: 62.h,
                        minWidth: Get.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg/mail.svg',
                              height: 20.h,
                              width: 24.w,
                            ),
                            SizedBox(width: 14.w),
                            Text(
                              'Sign in with email',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.sp),
                            ),
                          ],
                        ),
                        color: PickColor.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Lottie.asset('assets/images/png/no_internet2.json')),
                SizedBox(height: 30.h),
                Text('Please Check Your Internet Connection',
                    style: TextStyle(
                        fontSize: 20.sp, color: PickColor.buttonColor)),
              ],
            );
          }
        },
      ),
    );
  }
}

Widget button({
  required VoidCallback onPressed,
  required Color colorSide,
  Color? color,
  required String name,
  required Color textColor,
  required double fontSize,
  required FontWeight? fontWeight,
}) {
  return MaterialButton(
    onPressed: onPressed,
    child: Text(
      name,
      style: TextStyle(
          color: textColor, fontSize: fontSize, fontWeight: fontWeight),
    ),
    height: 62.h,
    minWidth: 170.w,
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
      side: BorderSide(color: colorSide),
    ),
  );
}
