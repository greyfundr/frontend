// lib/core/network/token_manager.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:greyfundr/services/shared_preference_service.dart';
import 'package:greyfundr/shared/environment.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static final SharedPreferences _prefs = SharedPreferenceService.prefs;
  final Dio _dio = Dio();

  // Replace with your actual refresh token endpoint
  static String _refreshTokenEndpoint = '${env.host}auth/refresh';

  Future<String>? _refreshing; // shared in-flight refresh

  // Get access token - returns stored token if valid, otherwise refreshes
  Future<String> getAccessToken() async {
    final token = _prefs.getString(_accessTokenKey);
    final expiryString = _prefs.getString(_tokenExpiryKey);

    // If no token exists, return empty to trigger auth flow
    if (token == null || token.isEmpty) {
      log('No access token found');
      return '';
    }

    // Check if token is expired
    if (expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        log('Token expired, attempting refresh');
        // If a refresh is already running, await it
        if (_refreshing != null) {
          try {
            return await _refreshing!;
          } catch (_) {
            return '';
          }
        }
        // Start a single refresh and share it
        final completer = Completer<String>();
        _refreshing = completer.future;
        try {
          final newToken = await refreshToken();
          completer.complete(newToken);
          return newToken;
        } catch (e) {
          completer.completeError(e);
          return '';
        } finally {
          _refreshing = null;
        }
      }
    }
    // log("ACCESS TOKEN FROM TOKEN MANAGEMENT ${token}");
    return token;
  }

  // Check if token is valid (not expired)
  Future<bool> isTokenValid() async {
    final expiryString = _prefs.getString(_tokenExpiryKey);

    if (expiryString == null) return false;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isBefore(expiry);
  }

  // Save tokens and expiry
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
    await _prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
    log('Tokens saved successfully');
  }

  // Clear all tokens (for logout)
  // Future<void> clearTokens() async {
  //   await _prefs.remove(_accessTokenKey);
  //   await _prefs.remove(_refreshTokenKey);
  //   await _prefs.remove(_tokenExpiryKey);
  //   log('Tokens cleared');
  // }

  // Refresh the access token using refresh token
  Future<String> refreshToken() async {
    final refreshToken = _prefs.getString(_refreshTokenKey);

    log("CURRENT REFRESH TOKEN ::::::: $refreshToken ");
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    try {
      final response = await _dio.get(
        _refreshTokenEndpoint,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': "Bearer ${_prefs.getString(_refreshTokenKey)}",
          },
        ),
      );

      log(":::::::: TOKEN REFRESH RESPONSE$response");
      // Parse response and extract tokens
      final data = response.data;
      String newAccessToken = data["data"]['accessToken'];
      String newRefreshToken = data["data"]['refreshToken'];
      log("NEW REFRESH TOKEN GOTTEN :::: ${newRefreshToken}");

      // Calculate expiry from JWT or from response
      DateTime? expiry;

      try {
        final parts = newAccessToken.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          if (payload['exp'] != null) {
            expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
          } else {
            // Fallback to 15 minutes if 'exp' not present
            expiry = DateTime.now().add(Duration(minutes: 15));
          }
        }
      } catch (e) {
        log('Error parsing JWT: $e');
      }

      // Save new tokens
      await saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiry: expiry!,
      );
      log('Token refreshed successfully');
      return newAccessToken;
    } catch (e, stacktrace) {
      log('Failed to refresh token: $e ::::::::::$stacktrace');
      await Sentry.captureException(e, stackTrace: stacktrace);
      // logOut(fromRetry: true);
      throw Exception('Token refresh failed');
    }
  }

  // Check if refresh token is expired
  Future<bool> isRefreshTokenExpired() async {
    final refreshToken = _prefs.getString(_refreshTokenKey);

    if (refreshToken == null || refreshToken.isEmpty) {
      return true; // No refresh token means it's effectively expired
    }

    try {
      final parts = refreshToken.split('.');
      if (parts.length == 3) {
        final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        if (payload['exp'] != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(
            payload['exp'] * 1000,
          );
          return DateTime.now().isAfter(expiry);
        }
      }
    } catch (e, stacktrace) {
      log('Error parsing refresh token JWT: $e :::::: $stacktrace');
    }

    // If unable to parse, assume expired
    return true;
  }
}
