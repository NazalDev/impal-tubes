class Failure implements Exception {
  final String message;
  Failure([this.message = "An Unexpected error occurred."]);
}
