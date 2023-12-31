import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itistore/views/screens/botttom_nav_screen.dart';
import 'package:itistore/views/screens/signup_screen.dart';
import 'package:itistore/views/widgets/custom_button.dart';
import 'package:itistore/views/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constants.dart';
import '../../models/user_data_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/shoe.png',
                      width: 20.w,
                      height: 20.h,
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                //-----------email--------------
                CustomTextFormField(
                  lableText: 'Email',
                  iconn: Icons.email,
                  textStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  textType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: validateEmail,
                ),
                SizedBox(height: 3.h),
                //-----------password--------------
                CustomTextFormField(
                  lableText: 'Password',
                  hideText: true,
                  iconn: Icons.lock,
                  textStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  textType: TextInputType.visiblePassword,
                  controller: passwordController,
                  validator: validatePassword,
                ),
                SizedBox(height: 8.h),
                CustomButton(
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: kPrimaryColor,
                  splashColor: Colors.purple,
                  height: 8.h,
                  width: 100.w,
                  onTap: _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.sp,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (!Navigator.canPop(context)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ));
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        ' Sign up',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        DocumentSnapshot userDataSnapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        Map<String, dynamic> userData =
            userDataSnapshot.data() as Map<String, dynamic>;

        if (context.mounted) {
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserData(userData);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavBar(),
            ),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // ignore: use_build_context_synchronously
          showSnackBar(context, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          // ignore: use_build_context_synchronously
          showSnackBar(context, 'Wrong password provided for that user.');
        } else {
          // ignore: use_build_context_synchronously
          showSnackBar(context, e.message.toString());
        }
      } finally {
        setState(() {
          _isLoading = false; // Hide progress indicator
        });
      }
    }
  }

  String? validateEmail(value) {
    if (value == null || value.isEmpty) {
      return 'Email Address is required.';
    }
    String pattern = r'\w+@\w+\.\w+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Invalid Email Address format.';
    }
    return null;
  }

  String? validatePassword(value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Must be more than 8 charater';
    }
    return null;
  }
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: kPrimaryColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(24),
      duration: const Duration(seconds: 1, milliseconds: 50),
    ),
  );
}
