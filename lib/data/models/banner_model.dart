import 'package:json_annotation/json_annotation.dart';

part 'banner_model.g.dart';

@JsonSerializable()
class BannerModel {
  final int id;
  final String type;
  final String url;
  final int duration;
  final String? title;
  final String? description;
  final String? imageSource;
  final int position;
  final bool active;
  final List<BannerEventEntry>? eventEntries;
  final int? eventEntryId;

  BannerModel({
    required this.id,
    required this.type,
    required this.url,
    required this.duration,
    this.title,
    this.description,
    this.imageSource,
    required this.position,
    required this.active,
    this.eventEntries,
    this.eventEntryId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}

@JsonSerializable()
class BannerEventEntry {
  final int id;
  final String name;
  final String pictureUrl;
  final int position;
  final int? duration;

  BannerEventEntry({
    required this.id,
    required this.name,
    required this.pictureUrl,
    required this.position,
    this.duration,
  });

  factory BannerEventEntry.fromJson(Map<String, dynamic> json) =>
      _$BannerEventEntryFromJson(json);

  Map<String, dynamic> toJson() => _$BannerEventEntryToJson(this);
}
