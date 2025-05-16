

import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toury/core/functions/navigation.dart';
import 'package:toury/core/utils/text_style.dart';
import 'package:toury/featuers/intro/pages/onboarding/presentation/screen/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        pushReplacement(context,const OnboardingScreen()); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
   

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/images/logo.json",
              width: 200.w,
              height: 200.h 
            ),
            SizedBox(height: 20.h), 
            Text(
              "طيور الزهراء",
              style: getTitleStyle(), 
            ),
            SizedBox(height: 10.h), 
            Text(
              "أهلاً بيك في طيور الزهراء 🐔",
              style: getSmallStyle(),
            ),
          ],
        ),
      ),
    );
  }
}
