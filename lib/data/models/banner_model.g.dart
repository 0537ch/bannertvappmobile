// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  url: json['url'] as String,
  duration: (json['duration'] as num).toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  imageSource: json['imageSource'] as String?,
  position: (json['position'] as num).toInt(),
  active: json['active'] as bool,
  eventEntries: (json['eventEntries'] as List<dynamic>?)
      ?.map((e) => BannerEventEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  eventEntryId: (json['eventEntryId'] as num?)?.toInt(),
);

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'url': instance.url,
      'duration': instance.duration,
      'title': instance.title,
      'description': instance.description,
      'imageSource': instance.imageSource,
      'position': instance.position,
      'active': instance.active,
      'eventEntries': instance.eventEntries,
      'eventEntryId': instance.eventEntryId,
    };

BannerEventEntry _$BannerEventEntryFromJson(Map<String, dynamic> json) =>
    BannerEventEntry(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      pictureUrl: json['pictureUrl'] as String,
      position: (json['position'] as num).toInt(),
      duration: (json['duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BannerEventEntryToJson(BannerEventEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'pictureUrl': instance.pictureUrl,
      'position': instance.position,
      'duration': instance.duration,
    };
