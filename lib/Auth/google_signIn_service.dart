import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

String? email;
String? image;
String? name;
Future<bool> googleServices() async {
  final GoogleSignInAccount? googleSignInAccount =
      await GoogleSignIn().signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;
  final AuthCredential authCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken);
  print('=======>>>>${authCredential}');
  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(authCredential);
  User? user = userCredential.user;

  name = user!.displayName;
  image = user.photoURL;
  email = user.email;

  return true;
}

Future googleSignOut() async {
  await GoogleSignIn().signOut();
}
