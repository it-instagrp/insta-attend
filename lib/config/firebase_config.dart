import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../firebase_options_qa.dart';
import 'app_config.dart';

FirebaseOptions getFirebaseOptions(AppEnvironment environment) {
  switch (environment) {
    case AppEnvironment.qa:
      return DefaultFirebaseOptionsQa.currentPlatform;

    case AppEnvironment.prod:
      return DefaultFirebaseOptions.currentPlatform;
  }
}
