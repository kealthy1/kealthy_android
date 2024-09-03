import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const key = 'customCache';

  CustomCacheManager() : super(Config(
    key,
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 20,
    repo: JsonCacheInfoRepository(databaseName: key),
    fileService: HttpFileService(),
  ));
}
