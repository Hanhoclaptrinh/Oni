import 'package:frontend/data/models/User.dart';
import 'package:frontend/data/models/LatestMessage.dart';

class Conversation {
  final String id;
  final String type;
  final List<User> members;
  final String? name;
  final String? avatarUrl;
  final String? createdBy;
  final LatestMessage? latestMessage;
  final User? otherUser;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.type,
    required this.members,
    this.name,
    this.avatarUrl,
    this.createdBy,
    this.latestMessage,
    this.otherUser,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json["_id"] ?? "", 
      type: json["type"] ?? "private",
      members: json["members"] != null
          ? (json["members"] as List).map((m) => User.fromJson(m)).toList()
          : [],
      name: json["name"],
      avatarUrl: json["avatarUrl"],
      createdBy: json["createdBy"],
      latestMessage: json["latestMessage"] != null
          ? LatestMessage.fromJson(json["latestMessage"])
          : null,
      otherUser: json["otherUser"] != null
          ? User.fromJson(json["otherUser"])
          : null,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }

  String? get avatarSafe {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    return avatarUrl;
  }

  String? get otherAvatarSafe {
    final url = otherUser?.avatarUrl;
    if (url == null || url.isEmpty) return null;
    return url;
  }

  String? get finalAvatar {
    if (type == "private") return otherAvatarSafe;
    return avatarSafe;
  }

  String get displayNameSafe {
    if (type == "private") {
      return otherUser?.displayName ?? "Unknown";
    }
    return name ?? "Group Chat";
  }
}
