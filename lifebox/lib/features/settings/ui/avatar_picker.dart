import 'package:flutter/material.dart';

class DefaultAvatar {
  final String id;
  final IconData icon;
  final Color bg;

  const DefaultAvatar(this.id, this.icon, this.bg);
}

/// 12 个默认头像（参照你第3张图：网格选择）
const defaultAvatars = <DefaultAvatar>[
  DefaultAvatar('a1', Icons.person, Color(0xFFDCE775)),
  DefaultAvatar('a2', Icons.person_outline, Color(0xFFB3E5FC)),
  DefaultAvatar('a3', Icons.face, Color(0xFFFFCCBC)),
  DefaultAvatar('a4', Icons.sports_soccer, Color(0xFFC5CAE9)),
  DefaultAvatar('a5', Icons.emoji_people, Color(0xFFFFF59D)),
  DefaultAvatar('a6', Icons.woman, Color(0xFFB2DFDB)),
  DefaultAvatar('a7', Icons.man, Color(0xFFFFECB3)),
  DefaultAvatar('a8', Icons.school, Color(0xFFD7CCC8)),
  DefaultAvatar('a9', Icons.work, Color(0xFFE1BEE7)),
  DefaultAvatar('a10', Icons.child_friendly, Color(0xFFC8E6C9)),
  DefaultAvatar('a11', Icons.pets, Color(0xFFFFCDD2)),
  DefaultAvatar('a12', Icons.elderly, Color(0xFFCFD8DC)),
];

DefaultAvatar avatarById(String id) {
  return defaultAvatars.firstWhere(
    (e) => e.id == id,
    orElse: () => defaultAvatars.first,
  );
}

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.avatarId,
    this.radius = 20,
    this.imageUrl,
  });

  final String avatarId;
  final double radius;

  /// 如果你后续实现“上传图片”，把 imageUrl 或 FileImage 接进来即可
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    final a = avatarById(avatarId);
    return CircleAvatar(
      radius: radius,
      backgroundColor: a.bg,
      child: Icon(a.icon, color: Colors.black87),
    );
  }
}

Future<String?> showAvatarPickerSheet(
  BuildContext context, {
  required String selectedId,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: false,
    showDragHandle: true,
    builder: (ctx) {
      final bottom = MediaQuery.of(ctx).viewInsets.bottom;

      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'プロフィール画像',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('終了'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // ✅ 关键：避免嵌套滚动冲突
                itemCount: defaultAvatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (_, i) {
                  final a = defaultAvatars[i];
                  final selected = a.id == selectedId;
                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.pop(ctx, a.id),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AvatarCircle(avatarId: a.id, radius: 34),
                        if (selected)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black87,
                              child: const Icon(Icons.check,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}
