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
    return Autocomplete<LocationModel>(
      initialValue: TextEditingValue(text: selectedLocation?.name ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return locations;
        }
        return locations.where((LocationModel option) {
          return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (LocationModel option) => option.name,
      onSelected: (LocationModel selection) {
        onSelected(selection);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Search Location',
            border: OutlineInputBorder(),
            filled: true,
            suffixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.only(
              top: 12,
              bottom: 12 + bottomPadding,
              left: 16,
              right: 16,
            ),
          ),
          onSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
    );
  }
}
