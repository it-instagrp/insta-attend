import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_attend/View/pages/homescreen.dart';
import 'package:insta_attend/Helper/get_di.dart' as di;
import 'package:insta_attend/View/pages/splash_screen.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "InstaAttend",
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        textTheme: GoogleFonts.interTextTheme()
      ),
      home: SplashScreen(),
    );
  }
}
