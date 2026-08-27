enum AppEnvironment {
  qa,
  prod,
}

class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String apiBaseUrl;

  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
  });

  static const qa = AppConfig(
    environment: AppEnvironment.qa,
    appName: 'Insta Attend Test',
    apiBaseUrl: 'https://test-api.ams.instagrp.in/api/',
  );

  static const prod = AppConfig(
    environment: AppEnvironment.prod,
    appName: 'Insta Attend',
    apiBaseUrl: 'https://api.ams.instagrp.in/api/',
  );

  static AppConfig current = prod;

  static void setEnvironment(AppEnvironment environment) {
    current = switch (environment) {
      AppEnvironment.qa => qa,
      AppEnvironment.prod => prod,
    };
  }
}
