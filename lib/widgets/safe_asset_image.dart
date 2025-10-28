import 'dart:convert';
// no direct typed_data needed anymore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// SafeAssetImage
///
/// Usage: SafeAssetImage('assets/images/foo.png')
///
/// Behaviors:
/// - Normalizes the path (removes leading slash) and logs if present.
/// - Validates the asset is declared in AssetManifest.json.
/// - Renders using Image.asset and supplies an [errorBuilder] to show a
///   fallback (by default a centered error icon) and log codec failures.
/// - Attempts a non-awaited precache in the builder to warm the image cache.
class SafeAssetImage extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final double? width;
  final Widget? fallback;
  final Alignment alignment;

  const SafeAssetImage(
    this.assetPath, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.fallback,
    this.alignment = Alignment.center,
  });

  static Future<Set<String>>? _manifestCache;

  static Future<Set<String>> _loadAssetManifest() {
    if (_manifestCache != null) return _manifestCache!;
    _manifestCache = rootBundle
        .loadString('AssetManifest.json')
        .then((s) {
          try {
            final Map<String, dynamic> m =
                json.decode(s) as Map<String, dynamic>;
            return m.keys.toSet();
          } catch (e) {
            debugPrint(
              'SafeAssetImage: failed to parse AssetManifest.json: $e',
            );
            return <String>{};
          }
        })
        .catchError((e) {
          debugPrint('SafeAssetImage: failed to load AssetManifest.json: $e');
          return <String>{};
        });
    return _manifestCache!;
  }

  String _normalize(String p) {
    if (p.startsWith('/')) {
      final np = p.substring(1);
      debugPrint(
        'SafeAssetImage: removed leading slash from asset path: "$p" -> "$np"',
      );
      return np;
    }
    return p;
  }

  // Legacy header checks were removed because they proved brittle across
  // build modes and image encodings. We now validate only that the asset
  // is declared in AssetManifest.json and then rely on Image.asset's
  // errorBuilder to gracefully handle decode/codec failures at render time.
  Future<bool> _assetDeclared(String normalized) async {
    try {
      final manifest = await _loadAssetManifest();
      if (!manifest.contains(normalized)) {
        debugPrint(
          'SafeAssetImage: asset not declared in AssetManifest.json: "$normalized"',
        );
        return false;
      }
      return true;
    } catch (e, st) {
      debugPrint(
        'SafeAssetImage: error checking AssetManifest for "$normalized": $e',
      );
      debugPrint(st.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _normalize(assetPath);
    return FutureBuilder<bool>(
      future: _assetDeclared(normalized),
      builder: (ctx, snap) {
        final ok =
            snap.connectionState == ConnectionState.done && snap.data == true;
        if (!ok) {
          // show fallback while loading or on validation failure
          return fallback ?? const Center(child: Icon(Icons.broken_image));
        }

        // Asset validated. Use Image.asset with errorBuilder to catch codec
        // failures at render-time and show a graceful fallback. Also attempt
        // to precache (non-awaited) to warm the cache.
        try {
          final ai = AssetImage(normalized);
          // non-awaited precache; will log on error via catchError
          precacheImage(ai, context).catchError((e) {
            debugPrint('SafeAssetImage: precache failed for "$normalized": $e');
          });
          return Image.asset(
            normalized,
            width: width ?? double.infinity,
            fit: fit,
            alignment: alignment,
            errorBuilder: (c, e, st) {
              debugPrint(
                'SafeAssetImage: Image.asset error for "$normalized": $e',
              );
              debugPrint(st.toString());
              return fallback ?? const Center(child: Icon(Icons.broken_image));
            },
          );
        } catch (e, st) {
          debugPrint(
            'SafeAssetImage: unexpected exception building Image.asset for "$normalized": $e',
          );
          debugPrint(st.toString());
          return fallback ?? const Center(child: Icon(Icons.broken_image));
        }
      },
    );
  }
}
