import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bannertvapp/data/models/banner_model.dart';

class ImageBanner extends StatelessWidget {
  final BannerModel banner;

  const ImageBanner({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CachedNetworkImage(
        imageUrl: banner.url,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Center(
          child: Icon(Icons.error, size: 64, color: Colors.red),
        ),
      ),
    );
  }
}
