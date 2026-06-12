import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
abstract class Store with _$Store {
  const factory Store({
    required String ownerId,
    required String storeName,
    required String storeAddress,
    required String storeRoadAddress,
    required String storePhone,
    required String storeImage,
    required DateTime storeCreatedAt,
    required DateTime storeUpdatedAt,
    @GeoPointConverter() required GeoPoint location,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
} 

class GeoPointConverter implements JsonConverter<GeoPoint, Object> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Object json) {
    // Firestore에서 읽어온 값은 보통 GeoPoint 그대로 들어옴
    if (json is GeoPoint) return json;

    // 혹시 {lat: , lng: } 형태로 저장한 경우도 대응
    if (json is Map<String, dynamic>) {
      final lat = (json['lat'] as num).toDouble();
      final lng = (json['lng'] as num).toDouble();
      return GeoPoint(lat, lng);
    }

    throw ArgumentError('GeoPointConverter: unsupported type: ${json.runtimeType}');
  }

  @override
  Object toJson(GeoPoint object) => object; // Firestore는 GeoPoint 그대로 저장 가능
}