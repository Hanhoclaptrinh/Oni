class Media {
  final String url;
  final String type; // image | video | audio | file
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
    type: json["type"],
    size: json["size"],
    width: json["width"],
    height: json["height"],
    duration: json["duration"]?.toDouble(),
    format: json["format"],
  );
}
