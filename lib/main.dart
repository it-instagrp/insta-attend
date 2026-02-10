import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_attend/Helper/get_di.dart' as di;
import 'package:insta_attend/View/pages/splash_screen.dart';
import 'package:insta_attend/firebase_options.dart';
import 'Utils/notification_service.dart';

// Top-level function to handle background/closed messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  NotificationService.showNotification(message);
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 2. Initialize Local Notifications
  await NotificationService.initialize();

  // 3. Handle Background/Closed state notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. Handle Foreground state notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationService.showNotification(message);
  });

  // 5. Dependency Injection
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Insta Attend",
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        textTheme: GoogleFonts.interTextTheme()
      ),
      home: SplashScreen(),
    );
  }
}
