import 'package:frontend/core/utils/Enums.dart';

class Media {
  final String url;
  final MediaType type; // image | video | audio | file
  final int? size;
  final int? width;
  final int? height;
  final double? duration;
  final String? format;

  Media({
    required this.url,
    required this.type,
    this.size,
    this.width,
    this.height,
    this.duration,
    this.format,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    url: json["url"],
    type: MediaType.values.firstWhere((e) => e.name == json["type"]),
    size: json["size"],
    width: json["width"],
    height: json["height"],
    duration: json["duration"]?.toDouble(),
    format: json["format"],
  );
}
