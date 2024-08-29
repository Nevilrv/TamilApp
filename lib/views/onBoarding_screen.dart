import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tamil_app/constant/color.dart';
import 'package:tamil_app/constant/common_button.dart';
import 'package:tamil_app/views/sign_in_screen.dart';

import '../constant/common_text.dart';
import '../constant/textname.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController? pageController;
  Timer? _timer;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (selector < 2) {
        selector++;
      } else {
        selector = 0;
      }

      pageController?.animateToPage(selector,
          duration: Duration(seconds: 2),
          curve: Curves.easeInOutCubicEmphasized);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  List<Map<String, dynamic>> onBoarding = [
    {
      'images': 'assets/images/svg/onboarding_1.svg',
      'title': TextName.onBoardingText1,
      'subTitle': TextName.onBoardingText2,
    },
    {
      'images': 'assets/images/svg/onBoarding_2.svg',
      'title': TextName.onBoardingText1,
      'subTitle': TextName.onBoardingText2,
    },
    {
      'images': 'assets/images/svg/onBoarding_3.svg',
      'title': TextName.onBoardingText1,
      'subTitle': TextName.onBoardingText2,
    },
  ];
  int selector = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  selector == 0
                      ? Text('')
                      : selector == 1
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  selector--;
                                  pageController?.animateToPage(selector,
                                      duration: Duration(seconds: 2),
                                      curve: Curves.easeInOutCubicEmphasized);
                                });
                              },
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 20.h,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  selector--;
                                  pageController?.animateToPage(selector,
                                      duration: Duration(seconds: 2),
                                      curve: Curves.easeInOutCubicEmphasized);
                                });
                              },
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 20.h,
                              ),
                            ),
                  Spacer(),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          () => SignInScreen(),
                        );
                      },
                      child: CommonText(
                        text: selector == 0
                            ? TextName.skip
                            : selector == 1
                                ? TextName.skip
                                : '',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: PickColor.secondary1TextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 122.h),
            Container(
              height: 550.h,
              // color: Colors.red,
              child: PageView(
                onPageChanged: (value) {
                  setState(() {
                    selector = value;
                  });
                },
                controller: pageController,
                children: List.generate(
                  onBoarding.length,
                  (index) => Column(
                    children: [
                      SvgPicture.asset(
                        '${onBoarding[index]['images']}',
                        height: 250.h,
                        width: 200.w,
                      ),
                      SizedBox(height: 60.h),
                      CommonText(
                        text: TextName.onBoardingText1,
                        fontSize: 26.sp,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 36.h),
                      CommonText(
                        text: TextName.onBoardingText2,
                        fontSize: 16.sp,
                        color: PickColor.secondary1TextColor,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 23.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  height: 5.91.h,
                  width: selector == index ? 16.26.w : 5.91.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    borderRadius: selector == index
                        ? BorderRadius.circular(1.r)
                        : BorderRadius.circular(0.r),
                    color: selector == index
                        ? PickColor.buttonColor
                        : PickColor.dullColor,
                  ),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CommonButton(
                onPressed: () {
                  if (selector == 2) {
                    Get.off(() => SignInScreen());
                  } else {
                    setState(() {
                      selector++;
                      pageController?.animateToPage(selector,
                          duration: Duration(seconds: 2),
                          curve: Curves.easeInOutCubicEmphasized);
                    });
                  }
                },
                text: selector == 2 ? 'Get Started' : 'Next',
              ),
            ),
            SizedBox(height: 31.h),
          ],
        ),
      ),
    );
  }
}
