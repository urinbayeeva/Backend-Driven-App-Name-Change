import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/dependencies.dart';
import 'core/config/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brand = await createBrandViewModel(const AppEnv.fromEnvironment());
  runApp(App(brand: brand));
  brand.start(); // Non-blocking: the app never waits for /app-config.
}
