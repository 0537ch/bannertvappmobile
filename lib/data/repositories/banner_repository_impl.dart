import 'package:bannertvapp/data/models/banner_model.dart';
import 'package:bannertvapp/data/models/location_model.dart';
import 'package:bannertvapp/domain/repositories/banner_repository.dart';
import 'package:bannertvapp/data/services/api_client.dart';

class BannerRepositoryImpl implements BannerRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<BannerModel>> getBanners(String slug) async {
    final data = await _apiClient.getJson('/api/banner/location/$slug');

    final bannersJson = data['banners'] as List;
    return bannersJson
        .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
        .where((banner) => banner.active && (banner.type == 'image' || banner.type == 'video' || banner.type == 'event'))
        .toList();
  }

  @override
  Future<List<LocationModel>> getLocations() async {
    final data = await _apiClient.getJson('/api/locations');

    final locationsJson = data['locations'] as List;
    return locationsJson
        .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Stream<void>> getSyncEvents() async {
    return _apiClient.sse('/api/banner/events');
  }
}
