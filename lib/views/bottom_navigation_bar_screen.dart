import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tamil_app/constant/color.dart';
import 'package:tamil_app/views/bootom_bar/help_screen.dart';
import 'package:tamil_app/views/bootom_bar/home_screen.dart';
import 'package:tamil_app/views/bootom_bar/profile_screen.dart';
import 'package:tamil_app/views/bootom_bar/subscription_screen.dart';

import '../controller/network_checker.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  List icon = [
    'assets/images/svg/home.svg',
    'assets/images/svg/star.svg',
    'assets/images/svg/help.svg',
    'assets/images/svg/profile.svg'
  ];
  List screen = [
    HomeScreen(),
    SubScrIPTionScreen(),
    HelpScreen(),
    ProfileScreen(),
  ];
  int selector1 = 0;

  ConnectivityProvider _connectivityProvider = Get.put(ConnectivityProvider());
  @override
  void initState() {
    _connectivityProvider.startMonitoring();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectivityProvider>(
      builder: (controller) {
        if (controller.isOnline!) {
          return Stack(
            children: [
              WillPopScope(
                onWillPop: () async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('Do you want to exit an App?',
                            style: TextStyle(color: PickColor.buttonColor)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.h),
                        ),
                        title: Text(
                          'Exit App',
                          style: TextStyle(color: PickColor.buttonColor),
                        ),
                        actions: [
                          MaterialButton(
                            color: PickColor.buttonColor,
                            minWidth: 80.w,
                            height: 50.h,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.h),
                            ),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          MaterialButton(
                            color: PickColor.buttonColor,
                            minWidth: 80.w,
                            height: 50.h,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.h),
                            ),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              'No',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
                child: Scaffold(
                  body: screen[selector1],
                ),
              ),
              Positioned(
                bottom: -10,
                child: Container(
                  height: 104.h,
                  width: Get.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.h),
                    child: Container(
                      height: 70.h,
                      width: 368.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade400,
                              offset: Offset(1, 2),
                              spreadRadius: 0.2,
                              blurRadius: 1),
                        ],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          icon.length,
                          (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selector1 = index;
                              });
                            },
                            child: SvgPicture.asset(
                              icon[index],
                              height: 29.h,
                              color: selector1 == index
                                  ? PickColor.buttonColor
                                  : Color(0xffAFAFAF),
                              width: 29.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Lottie.asset('assets/images/png/no_internet2.json')),
                SizedBox(height: 30.h),
                Text('Please Check Your Internet Connection',
                    style: TextStyle(
                        fontSize: 20.sp, color: PickColor.buttonColor)),
              ],
            ),
          );
        }
      },
    );
  }
}
