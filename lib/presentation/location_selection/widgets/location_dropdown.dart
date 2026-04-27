import 'package:flutter/material.dart';
import 'package:bannertvapp/data/models/location_model.dart';

class LocationDropdown extends StatelessWidget {
  final List<LocationModel> locations;
  final LocationModel? selectedLocation;
  final Function(LocationModel) onSelected;

  const LocationDropdown({
    super.key,
    required this.locations,
    required this.selectedLocation,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<LocationModel>(
      initialValue: selectedLocation,
      decoration: InputDecoration(
        labelText: 'Select Location',
        border: OutlineInputBorder(),
        filled: true,
      ),
      items: locations.map((location) {
        return DropdownMenuItem(
          value: location,
          child: Text(location.name),
        );
      }).toList(),
      onChanged: (location) {
        if (location != null) {
          onSelected(location);
        }
      },
    );
  }
}
