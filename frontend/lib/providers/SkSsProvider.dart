import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/services/SkSsService.dart';

final skSsServiceProvider = Provider<SkSsService>((ref) {
  return SkSsService(ref);
});
