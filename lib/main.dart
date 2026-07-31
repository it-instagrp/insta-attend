import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import 'package:insta_attend/API/app_constants.dart';
import 'package:insta_attend/Helper/get_di.dart' as di;
import 'package:insta_attend/Utils/location_service_manager.dart';
import 'package:insta_attend/Utils/notification_service.dart';
import 'package:insta_attend/View/pages/no_internet_gate.dart';
import 'package:insta_attend/View/pages/splash_screen.dart';
import 'package:insta_attend/firebase_options.dart';

// Top-level function to handle background/closed messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  NotificationService.showNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize Local Notifications
  await NotificationService.initialize();

  // 3. Handle Background/Closed state notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. Handle Foreground state notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationService.showNotification(message);
  });

  // 5. Dependency Injection (SharedPreferences, ApiClient, Repositories, Controllers)
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocationServiceManager.instance.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocationServiceManager.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Trigger session validation when returning to foreground
      debugPrint("App resumed: Checking active session validity...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: globalNavigatorKey,
        title: "Insta Attend",
        theme: ThemeData(
          primaryColor: Colors.lightBlueAccent,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
          textTheme: GoogleFonts.interTextTheme(),
        ),
        builder: (context, child) => NoInternetGate(child: child!),
        home: const SplashScreen(),
      ),
    );
  }
}