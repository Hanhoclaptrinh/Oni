import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/data/local/LocalStorageService.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:logger/logger.dart';

// dio dùng chung cho toàn app
// không tạo nhiều dio
// BUG siuuuuu toa khổng lồ khi AT expired
final dioProvider = Provider((ref) {
  final local = LocalStorageService();

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final refreshDio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  bool isRefreshing = false;
  Completer<void>? refreshCompleter;

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (reqOptions, handler) async {
        final at = await local.getAccessToken();
        if (at != null) {
          reqOptions.headers["Authorization"] = "Bearer $at";
        }
        handler.next(reqOptions);
      },

      onError: (error, handler) async {
        // không có res
        if (error.response == null) {
          return handler.next(error);
        }

        // 401
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        Logger().w("401 Detected. checking refresh...");

        final rt = await local.getRefreshToken();
        if (rt == null) {
          Logger().e("No Refresh Token found. Logout.");
          await local.clear();
          return handler.next(error);
        }

        // refresh logic
        if (!isRefreshing) {
          isRefreshing = true;
          refreshCompleter = Completer<void>();
          Logger().i("Starting Token Refresh...");

          try {
            final newTokens = await refreshDio.post(
              "/auth/refresh",
              data: {"refreshToken": rt},
            );

            Logger().d("Refresh Response: ${newTokens.statusCode}");

            final freshAT = newTokens.data["data"]["newAccessToken"];
            final freshRT = newTokens.data["data"]["newRefreshToken"];

            await local.saveTokens(freshAT, freshRT);
            Logger().i("Tokens saved. Reconnecting socket...");

            SocketService().reconnect(freshAT);

            refreshCompleter?.complete();
          } catch (e) {
            Logger().e("Refresh Failed: $e");
            refreshCompleter?.completeError("refresh_failed");
            await local.clear();
            return handler.next(error);
          } finally {
            isRefreshing = false;
          }
        }

        try {
          // các req khác đợi refresh xong
          await refreshCompleter?.future;
        } catch (e) {
          Logger().e("Waiter failed: $e");
          return handler.next(error);
        }

        // retry
        try {
          Logger().i("Retrying request...");
          final newAT = await local.getAccessToken();

          // copy options de tranh bi duplicate header
          final options = Options(
            method: error.requestOptions.method,
            headers: {
              ...error.requestOptions.headers,
              "Authorization": "Bearer $newAT",
            },
          );

          final newReq = await dio.request(
            error.requestOptions.path,
            options: options,
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
          );

          Logger().i("Retry Success!");
          return handler.resolve(newReq);
        } catch (e) {
          // neu retry ma van chet thi tra ve loi
          Logger().e("Retry Failed: $e");
          return handler.next(error);
        }
      },
    ),
  );

  return dio;
});
