import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/models/split_user_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';

import 'package:http_parser/http_parser.dart';


class SplitbillApiImpl implements SplitbillApi {
  final ApiClient _apiClient = ApiClient();

}