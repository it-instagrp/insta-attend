import 'config/app_config.dart';
import 'main.dart';

Future<void> main() async {
  await runAppWithEnvironment(
    AppEnvironment.qa,
  );
}
