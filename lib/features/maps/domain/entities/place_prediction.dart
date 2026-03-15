/// A place prediction from autocomplete search.
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    this.types = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacePrediction &&
          runtimeType == other.runtimeType &&
          placeId == other.placeId;

  @override
  int get hashCode => placeId.hashCode;
}
