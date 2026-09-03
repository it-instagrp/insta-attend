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

import 'config/app_config.dart';
import 'config/firebase_config.dart';

/// This is set by the environment entry point before the app starts.
///
/// QA:
/// main_qa.dart -> AppEnvironment.qa
///
/// Production:
/// main_prod.dart -> AppEnvironment.prod
AppEnvironment? _currentEnvironment;

/// Handles Firebase messages received when the app is in
/// background or completely closed.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the same environment as the main app.
  //
  // The background isolate does not necessarily have access to the
  // Firebase instance initialized in the main isolate.
  final environment = _currentEnvironment ?? AppEnvironment.prod;

  await Firebase.initializeApp(
    options: getFirebaseOptions(environment),
  );

  await NotificationService.initialize();

  NotificationService.showNotification(message);
}

/// Common application entry point.
///
/// main_qa.dart and main_prod.dart call this function with
/// the appropriate environment.
Future<void> runAppWithEnvironment(
  AppEnvironment environment,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Store environment so the Firebase background handler
  // knows which Firebase project to initialize.
  _currentEnvironment = environment;
  AppConfig.setEnvironment(environment);

  // Initialize Firebase for the selected environment.
  await Firebase.initializeApp(
    options: getFirebaseOptions(environment),
  );

  // Initialize local notifications.
  await NotificationService.initialize();

  // Register Firebase Messaging background handler.
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // Handle foreground notifications.
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      NotificationService.showNotification(message);
    },
  );

  // Dependency Injection
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
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        "App resumed: Checking active session validity...",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,

        navigatorKey: globalNavigatorKey,

        title: AppConfig.current.appName,

        theme: ThemeData(
          primaryColor: Colors.lightBlueAccent,

          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlueAccent,
          ),

          textTheme: GoogleFonts.interTextTheme(),
        ),

        builder: (context, child) {
          return NoInternetGate(
            child: child!,
          );
        },

        home: const SplashScreen(),
      ),
    );
  }
}
