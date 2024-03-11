import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key ? key}) : super(key: key);
  @override
  Widget build (BuildContext context) {
    return Center(child: AnimatedSplashScreen(
      splash: Image.asset('assets/dailyDash.png'),
      nextScreen: const MyHomePage(title: 'Flutter Demo Home Page'),
      backgroundColor: Colors.black,
      splashIconSize: 250,
      splashTransition: SplashTransition.fadeTransition,
      duration: 4000,
    ));
  }
}
