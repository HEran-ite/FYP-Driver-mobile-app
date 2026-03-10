/// Detailed information about a place.
class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingsTotal;
  final bool? isOpenNow;
  final List<String> types;
  final List<String> photoReferences;

  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.isOpenNow,
    this.types = const [],
    this.photoReferences = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceDetails &&
          runtimeType == other.runtimeType &&
          placeId == other.placeId;

  @override
  int get hashCode => placeId.hashCode;
}
