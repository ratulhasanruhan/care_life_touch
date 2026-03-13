class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }
    return 'ApiException($statusCode): $message';
  }
}

