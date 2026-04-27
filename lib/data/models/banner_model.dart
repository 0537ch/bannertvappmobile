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
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}
