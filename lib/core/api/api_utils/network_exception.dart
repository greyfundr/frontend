class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class NetworkException extends AppException {
  String? message;
  NetworkException([this.message]) : super(message, "No Internet ");
  @override
  String toString() {
    return " Unable to connect. Check your internet connection";
  }
}

class FileNotFoundException extends AppException {
  FileNotFoundException([String? message]) : super(message, "");
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Opss: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "");
}

class InternalServerErrorException extends AppException {
  InternalServerErrorException([String? message]) : super(message, "");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "");
}

class AlreadyRegisteredException extends AppException {
  AlreadyRegisteredException([String? message]) : super(message, "");
}
