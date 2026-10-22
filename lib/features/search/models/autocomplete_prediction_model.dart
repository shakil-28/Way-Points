/// Model representing a Google Places API Autocomplete prediction item
class AutocompletePredictionModel {
  final String placeId;
  final String primaryText;
  final String secondaryText;
  final String fullDescription;
  final List<String> types;

  const AutocompletePredictionModel({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
    required this.fullDescription,
    this.types = const [],
  });

  factory AutocompletePredictionModel.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    final mainText = structured?['main_text'] as String?;
    final secText = structured?['secondary_text'] as String?;
    final desc = json['description'] as String? ?? '';

    // Extract primary name and secondary address
    final primary = mainText ?? (desc.split(',').first.trim());
    final secondary = secText ?? (desc.contains(',') ? desc.substring(desc.indexOf(',') + 1).trim() : '');

    final rawTypes = json['types'] as List?;
    final parsedTypes = rawTypes?.map((t) => t.toString()).toList() ?? [];

    return AutocompletePredictionModel(
      placeId: json['place_id'] as String? ?? '',
      primaryText: primary,
      secondaryText: secondary,
      fullDescription: desc,
      types: parsedTypes,
    );
  }
}
