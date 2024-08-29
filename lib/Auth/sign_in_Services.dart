import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../constant/color.dart';

class EmailAuth {
  static Future<bool?> emailSignUp(String? email, String? password) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email!, password: password!)
        .catchError(
      (onError) {
        print('====>>>$onError');
      },
    );
    return true;
  }

  static Future<bool?> emailLogIn(String? email, String? password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email!, password: password!)
        .catchError(
      (onError) {
        print('Wrong password provided for that user.');
        Get.snackbar(
          'Oops!',
          'Wrong password provided for that user.',
          duration: Duration(seconds: 2),
          colorText: Colors.white,
          backgroundColor: PickColor.buttonColor,
        );

        print('====>>>$onError');
      },
    );
    return true;
  }

  static Future emailLogOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
