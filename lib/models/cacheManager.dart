import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyCacheManager extends CacheManager {
  static final MyCacheManager instance = MyCacheManager._internal();
  static const key = 'myCache';

  MyCacheManager._internal()
    : super(Config(key, stalePeriod: Duration(days: 1), maxNrOfCacheObjects: 300, ));

  factory MyCacheManager() => instance;
}
