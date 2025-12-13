import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/data/local/LocalStorageService.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/presentation/providers/AuthProvider.dart';

class SkSsService {
  final Ref ref;

  SkSsService(this.ref);

  // socket chỉ verify token 1 lần duy nhất lúc connect hoặc reconect
  // vrf lúc connect -> hết hạn -> ngưng vrf -> app die
  Future<void> ensureValidSocketSession() async {
    final local = LocalStorageService();
    final at = await local.getAccessToken();

    if (at == null) return;

    // AT còn hạn -> ok
    if (!JwtDecoder.isExpired(at)) return;

    final rt = await local.getRefreshToken();
    if (rt == null) return;

    final auth = ref.read(authRefreshServiceProvider);
    final result = await auth.refreshToken(rt);

    await local.saveTokens(result.accessToken, result.refreshToken);

    SocketService().reconnect(result.accessToken);
  }
}
