import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/brand/presentation/view_models/brand_view_model.dart';
import '../features/brand/presentation/views/home_page.dart';

class App extends StatelessWidget {
  const App({super.key, required this.brand});

  final BrandViewModel brand;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: brand,
      // MaterialApp.title also sets the app switcher label.
      builder: (context, child) => MaterialApp(
        title: brand.state.switcherName,
        theme: AppTheme.light,
        home: child,
      ),
      child: HomePage(viewModel: brand),
    );
  }
}
