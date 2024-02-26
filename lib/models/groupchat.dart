import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChat {
  final String groupId;
  final String groupAdminId;
  final String roomTitle;
  final List<String> memberIds;
  final Timestamp createdAt;
  final String groupImage;

  GroupChat({
    required this.groupId,
    required this.groupAdminId,
    required this.roomTitle,
    required this.memberIds,
    required this.createdAt,
    required this.groupImage,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) => GroupChat(
        groupId: json['group_id'] as String,
        groupAdminId: json['group_admin_id'] as String,
        roomTitle: json['room_title'] as String,
        memberIds: List<String>.from(json['member_ids']),
        createdAt: json['created_at'] as Timestamp,
        groupImage: json['group_image'] as String,
      );

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'group_admin_id': groupAdminId,
        'room_title': roomTitle,
        'member_ids': memberIds,
        'created_at': createdAt,
        'group_image': groupImage,
      };
}
