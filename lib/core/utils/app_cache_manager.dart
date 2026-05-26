import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Singleton CacheManager for all CachedNetworkImage calls in NeoShop.
///
/// Config:
///   maxNrOfCacheObjects — cap at 200 images (product grid + banners)
///   stalePeriod         — evict after 7 days
class AppCacheManager extends CacheManager with ImageCacheManager {
  static const _key = 'neoshop_image_cache';

  static final AppCacheManager instance = AppCacheManager._();

  AppCacheManager._()
      : super(Config(
          _key,
          maxNrOfCacheObjects: 200,
          stalePeriod: const Duration(days: 7),
        ));
}
