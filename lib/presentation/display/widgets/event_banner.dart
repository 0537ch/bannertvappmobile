import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bannertvapp/data/models/banner_model.dart';

class EventBanner extends StatelessWidget {
  final List<BannerEventEntry> entries;
  final int currentIndex;

  const EventBanner({
    super.key,
    required this.entries,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Expanded(
          child: entries[currentIndex].pictureUrl.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No Image',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: entries[currentIndex].pictureUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.error, size: 64, color: Colors.red),
                  ),
                ),
        ),
      ],
    );
  }
}