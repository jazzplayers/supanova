// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  ownerId: json['ownerId'] as String,
  storeName: json['storeName'] as String,
  storeAddress: json['storeAddress'] as String,
  storeRoadAddress: json['storeRoadAddress'] as String,
  storePhone: json['storePhone'] as String,
  storeImage: json['storeImage'] as String,
  storeCreatedAt: DateTime.parse(json['storeCreatedAt'] as String),
  storeUpdatedAt: DateTime.parse(json['storeUpdatedAt'] as String),
  location: const GeoPointConverter().fromJson(json['location'] as Object),
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'ownerId': instance.ownerId,
  'storeName': instance.storeName,
  'storeAddress': instance.storeAddress,
  'storeRoadAddress': instance.storeRoadAddress,
  'storePhone': instance.storePhone,
  'storeImage': instance.storeImage,
  'storeCreatedAt': instance.storeCreatedAt.toIso8601String(),
  'storeUpdatedAt': instance.storeUpdatedAt.toIso8601String(),
  'location': const GeoPointConverter().toJson(instance.location),
};
