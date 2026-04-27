import 'package:bannertvapp/data/models/banner_model.dart';
import 'package:bannertvapp/data/models/location_model.dart';

abstract class BannerRepository {
  Future<List<BannerModel>> getBanners(String slug);
  Future<List<LocationModel>> getLocations();
  Stream<void> getSyncEvents();
}
