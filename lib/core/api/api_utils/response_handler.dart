import 'dart:developer';

import 'package:dio/dio.dart';
  import 'package:greyfundr/core/models/api_response_model.dart';

import 'network_exception.dart';
// import 'package:http/http.dart' as api;

dynamic responseHandler(Response response, {bool hideLog = false}) async {
  log("in response handler");

  log("RESPONSE FROM HANDLER $response :::: URL :: ${response.realUri} ");
  String exceptionMsg;
  ApiResponse responseBody = ApiResponse();
  try {
    responseBody = apiResponseFromJson(response.toString());
    if (responseBody.message is List) {
      exceptionMsg = responseBody.message![0];
      // print("Error message From List ::::::: $exceptionMsg");
    } else {
      exceptionMsg = responseBody.message!;
      // handleErrorCustomly(exceptionMsg, response.statusCode.toString());
      // print("Error message::::::: $exceptionMsg");
    }
  } catch (e) {
    // print("Error deriving error message: $e");
    // exceptionMsg = response.data;
    exceptionMsg = "An  Error Occurred";
    // exceptionCode = response.statusCode.toString();
  }

  if (!hideLog) {
    // print(response.data);
  }

 

  switch (response.statusCode) {
    case 201:
      return response.data;
    case 200:
      return response.data;
    case 400:
      throw BadRequestException(exceptionMsg);
    case 401:
      throw UnauthorisedException(exceptionMsg);
    case 403:
      throw InternalServerErrorException(exceptionMsg);
    case 404:
      throw FileNotFoundException(exceptionMsg);
    case 422:
      //extract errors
      try {
        responseBody = apiResponseFromJson(response.data);
        exceptionMsg = responseBody.statusCode!.toString();
      } catch (e) {
        // print("could not extract errors");
      }

      throw AlreadyRegisteredException(exceptionMsg);
    case 500:
      throw InternalServerErrorException(exceptionMsg);

    default:
      throw FetchDataException('$exceptionMsg!');
  }
}


// handleErrorCustomly(String errorMessage, String? errorCode) {
//   log("Custom Error Handler Invoked :::::: $errorMessage");
//   if (errorMessage.contains("ERR-BD-001")) {
//     getX.Get.offAll(CustomBottomNav(), transition: getX.Transition.rightToLeft);
//     getX.Get.to(
//       NewVerficationScreen(),
//       transition: getX.Transition.rightToLeft,
//     );

//     switch (errorCode) {
//       case 400:
//         throw BadRequestException(errorMessage);
//       case 401:
//         throw UnauthorisedException(errorMessage);
//       case 403:
//         throw InternalServerErrorException(errorMessage);
//       case 404:
//         throw FileNotFoundException(errorMessage);
//       case 422:
//         //extract errors
//         // try {
//         //   responseBody = apiResponseFromJson(response.data);
//         //   errorMessage = responseBody.statusCode!.toString();
//         // } catch (e) {
//         //   // print("could not extract errors");
//         // }

//         throw AlreadyRegisteredException(errorMessage);
//       case 500:
//         throw InternalServerErrorException(errorMessage);

//       default:
//         throw FetchDataException('$errorMessage!');
//     }

//     // return;
//   }
// }
