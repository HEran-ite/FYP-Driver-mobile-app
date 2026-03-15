library;

class ServiceLocatorException implements Exception {
  ServiceLocatorException(this.message);
  final String message;
  @override
  String toString() => message;
}
