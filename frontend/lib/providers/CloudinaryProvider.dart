import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/services/CloudinaryService.dart';

final cloudinaryServiceProvider = Provider((ref) {
  return CloudinaryService();
});
