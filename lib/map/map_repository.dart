import 'package:geolocator/geolocator.dart';

abstract class MapRepository {
  Future<Position> getCurrentLocation({
    LocationAccuracy accuracy,
  });

  Stream<Position> streamPosition({
    LocationSettings? locationSettings,
  });

  Future<bool> isServiceEnabled();

  Future<LocationPermission> ensurePermission();
}

class MapRepositoryImpl implements MapRepository {
  /// 위치 서비스가 켜져 있는지 확인
  @override
  Future<bool> isServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// 위치 권한 확인 + 없으면 요청
  @override
  Future<LocationPermission> ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('위치 권한이 거부되었습니다.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 위치 권한을 허용해주세요.');
    }

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw Exception('위치 권한이 허용되지 않았습니다.');
    }

    return permission;
  }

  /// 위치 서비스 + 권한 사용 가능 상태인지 확인
  Future<void> _ensureReady() async {
    final serviceEnabled = await isServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('위치 서비스가 꺼져 있습니다. 기기 설정에서 위치 서비스를 켜주세요.');
    }

    await ensurePermission();
  }

  /// 현재 위치 1회 가져오기
  @override
  Future<Position> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    await _ensureReady();

    return Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        timeLimit: const Duration(seconds: 10),
      ),
    );
  }

  /// 실시간 위치 추적
  @override
  Stream<Position> streamPosition({
    LocationSettings? locationSettings,
  }) async* {
    await _ensureReady();

    final settings = locationSettings ??
        const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        );

    yield* Geolocator.getPositionStream(
      locationSettings: settings,
    );
  }
}