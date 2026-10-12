import 'package:flutter/material.dart';

/// Launcher artwork shown inside the app: the bundled icon in store builds,
/// the uploaded custom icon in direct builds.
class BrandIconTile extends StatelessWidget {
  const BrandIconTile.bundled(String iconKey, {super.key})
    : _iconKey = iconKey,
      _url = null;

  const BrandIconTile.remote(String url, {super.key})
    : _iconKey = null,
      _url = url;

  static const _size = 96.0;

  final String? _iconKey;
  final String? _url;

  @override
  Widget build(BuildContext context) {
    final url = _url;
    final image = url != null
        ? Image.network(
            url,
            width: _size,
            height: _size,
            // Hidden when it fails to load.
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          )
        : Image.asset(
            'assets/icons/$_iconKey.png',
            width: _size,
            height: _size,
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: ClipRRect(borderRadius: BorderRadius.circular(22), child: image),
      ),
    );
  }
}
