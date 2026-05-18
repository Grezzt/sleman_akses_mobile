class ApiException implements Exception {
  ApiException(this.message, {Map<String, List<String>>? fieldErrors})
    : fieldErrors = fieldErrors ?? {};

  final String message;
  final Map<String, List<String>> fieldErrors;
}
