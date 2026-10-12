import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/brand_state.dart';

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({super.key, required this.offer});

  final UpdateOffer offer;

  @override
  Widget build(BuildContext context) {
    final url = offer.url;
    return MaterialBanner(
      content: Text(offer.message),
      actions: [
        TextButton(
          onPressed: url == null
              ? null
              : () => launchUrl(url, mode: LaunchMode.externalApplication),
          child: const Text('UPDATE'),
        ),
      ],
    );
  }
}
