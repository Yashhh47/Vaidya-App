import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../view/widgets/common/loading_screen.dart';
import 'package:get/get.dart';

Future<UserCredential?> signInWithGoogle() async {
  // Show loading screen
  Get.dialog(
    const loading_screen(),
    barrierDismissible: false,
  );

  try {
    // Wait for both: sign-in and minimum 3 seconds delay
    final results = await Future.wait([
      GoogleSignIn().signIn().then((googleUser) async {
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await FirebaseAuth.instance.signInWithCredential(credential);
      }),
      Future.delayed(const Duration(seconds: 3)), // ensure 3 seconds minimum
    ]);

    // Close the loading dialog
    Get.back();

    return results[0] as UserCredential?;
  } catch (e) {
    Get.back(); // Close loading screen on error
    print('Error signing in with Google: $e');
    return null;
  }
}

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<User?> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    UserCredential result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
