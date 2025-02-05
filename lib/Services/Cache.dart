import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const String key = "customCache";

  static final CustomCacheManager _instance = CustomCacheManager._internal();

  factory CustomCacheManager() {
    return _instance;
  }

  CustomCacheManager._internal()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 4), // Expire cache after 7 days
            maxNrOfCacheObjects: 250, // Maximum number of cached items
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}
