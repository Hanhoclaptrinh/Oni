import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/AppConstants.dart';
import 'package:frontend/data/local/LocalStorageService.dart';

// dio dùng chung cho toàn app
// không tạo nhiều dio
// BUG siuuuuu toa khổng lồ khi AT expired
final dioProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final local = LocalStorageService();

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

        final rt = await local.getRefreshToken();
        if (rt == null) {
          await local.clear();
          return handler.next(error);
        }

        // refresh logic
        if (!isRefreshing) {
          isRefreshing = true;
          refreshCompleter = Completer();

          try {
            final newTokens = await dio.post(
              "/auth/refresh",
              data: {"refreshToken": rt},
            );

            final freshAT = newTokens.data["data"]["accessToken"];
            final freshRT = newTokens.data["data"]["refreshToken"];

            await local.saveTokens(freshAT, freshRT);
            refreshCompleter?.complete();
          } catch (_) {
            refreshCompleter?.completeError("refresh_failed");
            await local.clear();
            return handler.next(error);
          } finally {
            isRefreshing = false;
          }
        }

        // các req khác đợi refresh xong
        await refreshCompleter?.future;

        // retry
        final newAT = await local.getAccessToken();

        final newReq = await dio.request(
          error.requestOptions.path,
          options: Options(
            method: error.requestOptions.method,
            headers: {
              ...error.requestOptions.headers,
              "Authorization": "Bearer $newAT",
            },
          ),
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters,
        );

        return handler.resolve(newReq);
      },
    ),
  );

  return dio;
});
