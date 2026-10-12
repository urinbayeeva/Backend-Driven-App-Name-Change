import 'package:flutter/material.dart';

import '../view_models/brand_view_model.dart';
import '../widgets/brand_icon_tile.dart';
import '../widgets/update_banner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.viewModel});

  static const _directHint =
      'Direct build. Pull to re-sync with /app-config. The home screen name '
      'and icon come from the next build.';
  static const _storeHint =
      'Pull to re-sync with /app-config. Home screen name and icon change '
      'after the app goes to the background (Android).';

  final BrandViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;
        return Scaffold(
          appBar: AppBar(title: Text(state.inAppName)),
          body: Column(
            children: [
              if (state.updateOffer case final offer?)
                UpdateBanner(offer: offer),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.sync,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (!viewModel.isDirectBuild)
                        BrandIconTile.bundled(state.iconKey)
                      else if (state.customIconUrl case final url?)
                        BrandIconTile.remote(url),
                      Text(
                        state.inAppName,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.isDirectBuild ? _directHint : _storeHint,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
