import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NivexColors.textSecondary,
              letterSpacing: 0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: NivexColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NivexColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: children.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              thickness: 1,
              color: NivexColors.border,
            ),
            itemBuilder: (_, index) => children[index],
          ),
        ),
      ],
    );
  }
}
