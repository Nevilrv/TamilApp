import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamil_app/views/bottom_navigation_bar_screen.dart';
import 'package:tamil_app/views/onBoarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      Get.to(() => GetStorage().read('email') == null &&
              GetStorage().read('google') == null
          ? OnBoardingScreen()
          : BottomNavigationBarScreen());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          'assets/images/svg/splash.svg',
          height: 238.h,
          width: 238.w,
        ),
      ),
    );
  }
}
