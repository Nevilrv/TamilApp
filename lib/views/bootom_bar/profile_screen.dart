import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tamil_app/Auth/sign_in_Services.dart';
import 'package:tamil_app/constant/common_text.dart';
import 'package:tamil_app/views/bootom_bar/home_screen.dart';
import 'package:tamil_app/views/onBoarding_screen.dart';

import '../../constant/color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: Get.height,
        width: Get.width,
        color: Colors.black26.withOpacity(0.2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            HomeScreen(),
            Positioned(
              bottom: 20.h,
              child: Container(
                height: Get.height,
                width: Get.width,
                color: Colors.black26,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 81.w),
                      child: MaterialButton(
                        onPressed: () async {
                          await EmailAuth.emailLogOut()
                              .then((value) => Get.snackbar(
                                  'LogOut', 'Successful',
                                  colorText: Colors.white,
                                  backgroundColor: PickColor.buttonColor))
                              .whenComplete(
                                () => Get.to(
                                  () => OnBoardingScreen(),
                                ),
                              );
                          await GoogleSignIn().signOut();
                          GetStorage().remove('email');
                          GetStorage().remove('google');
                        },
                        height: 62.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg/arrow.svg',
                              height: 22.h,
                              width: 22.w,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            CommonText(
                              text: 'Log Out',
                              fontSize: 20.sp,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        color: Color(0xffBD5685),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
