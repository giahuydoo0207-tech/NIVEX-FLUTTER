import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/features/profile/domain/freelancer_profile.dart';
import 'package:nivex_flutter/features/profile/domain/reputation_tier.dart';
import 'package:nivex_flutter/features/profile/presentation/reputation_badges_screen.dart';
import 'package:nivex_flutter/features/profile/widgets/reputation_badge.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  State<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  final _controller = DemoFreelancerProfileController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = _controller.profile;
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Hồ sơ nghề nghiệp',
      subtitle: 'Thông tin doanh nghiệp nhìn thấy',
      showBackButton: true,
      actions: [
        IconButton(
          tooltip: 'Chỉnh sửa hồ sơ',
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) =>
                  EditProfessionalProfileScreen(controller: _controller),
            ),
          ),
          icon: const Icon(Icons.edit_outlined),
        ),
        const SizedBox(width: 8),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(profile: profile),
                const SizedBox(height: 14),
                _ProfileProgress(profile: profile),
                const SizedBox(height: 12),
                _ReputationEntry(
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const ReputationBadgesScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionTitle(
                  title: 'Giới thiệu',
                  icon: Icons.subject_rounded,
                ),
                const SizedBox(height: 8),
                _SectionSurface(
                  child: Text(
                    profile.bio,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionTitle(title: 'Kỹ năng', icon: Icons.code_rounded),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in profile.skills)
                      _Tag(label: skill, emphasized: skill == 'Flutter'),
                  ],
                ),
                const SizedBox(height: 22),
                const _SectionTitle(
                  title: 'Portfolio nổi bật',
                  icon: Icons.dashboard_customize_outlined,
                ),
                const SizedBox(height: 8),
                for (
                  var index = 0;
                  index < profile.projects.length;
                  index++
                ) ...[
                  _ProjectCard(project: profile.projects[index]),
                  if (index != profile.projects.length - 1)
                    const SizedBox(height: 10),
                ],
                const SizedBox(height: 22),
                const _SectionTitle(
                  title: 'Kinh nghiệm',
                  icon: Icons.work_outline_rounded,
                ),
                const SizedBox(height: 8),
                _SectionSurface(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < profile.experiences.length;
                        index++
                      ) ...[
                        _ExperienceTile(experience: profile.experiences[index]),
                        if (index != profile.experiences.length - 1)
                          Divider(height: 1, color: theme.divider),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionTitle(
                  title: 'Học vấn & chứng chỉ',
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 8),
                const _EducationCard(),
                const SizedBox(height: 22),
                _PrivacyNotice(visibility: profile.visibility),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final FreelancerProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ProfileHeaderBackgroundPainter(
                  variant: profile.profileHeaderTheme,
                  primary: theme.primary,
                  secondary: theme.success,
                  line: theme.border,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.surfaceSubtle,
                          foregroundImage: profile.avatarPath == null
                              ? null
                              : FileImage(File(profile.avatarPath!)),
                          child: profile.avatarPath == null
                              ? Icon(
                                  Icons.person_outline_rounded,
                                  color: theme.primary,
                                  size: 30,
                                )
                              : null,
                        ),
                        if (profile.isAvailable)
                          Positioned(
                            right: 1,
                            bottom: 1,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: theme.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '@${profile.username}',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AvailabilityBadge(isAvailable: profile.isAvailable),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  profile.headline,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _Meta(
                      icon: Icons.location_on_outlined,
                      label: profile.location,
                    ),
                    _Meta(
                      icon: Icons.schedule_rounded,
                      label: profile.timezone,
                    ),
                    _Meta(
                      icon: Icons.translate_rounded,
                      label: profile.languages.join(' · '),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: theme.divider),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _WorkMetric(
                        label: 'Hình thức',
                        value: profile.workPreference,
                      ),
                    ),
                    Container(width: 1, height: 34, color: theme.divider),
                    Expanded(
                      child: _WorkMetric(
                        label: 'Năng lực',
                        value: '${profile.weeklyCapacityHours} giờ/tuần',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderBackgroundPainter extends CustomPainter {
  const _ProfileHeaderBackgroundPainter({
    required this.variant,
    required this.primary,
    required this.secondary,
    required this.line,
  });

  final ProfileHeaderTheme variant;
  final Color primary;
  final Color secondary;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final subtle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primary.withValues(alpha: 0.10);
    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = secondary.withValues(alpha: 0.12);

    switch (variant) {
      case ProfileHeaderTheme.flow:
        for (var y = 18.0; y < size.height; y += 28) {
          final path = Path()..moveTo(size.width * .42, y);
          path.cubicTo(
            size.width * .62,
            y - 10,
            size.width * .78,
            y + 10,
            size.width + 8,
            y - 2,
          );
          canvas.drawPath(path, y % 56 == 18 ? accent : subtle);
        }
      case ProfileHeaderTheme.horizon:
        for (var index = 0; index < 4; index++) {
          final y = size.height * (.58 + index * .10);
          canvas.drawLine(
            Offset(size.width * .38, y),
            Offset(size.width, y),
            subtle,
          );
        }
        final sun = Paint()
          ..color = primary.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(size.width * .82, size.height * .27), 34, sun);
      case ProfileHeaderTheme.circuit:
        for (var x = size.width * .48; x < size.width; x += 34) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), subtle);
        }
        for (var y = 22.0; y < size.height; y += 32) {
          canvas.drawLine(
            Offset(size.width * .48, y),
            Offset(size.width, y),
            subtle,
          );
          canvas.drawCircle(Offset(size.width * .72, y), 2.2, accent);
        }
      case ProfileHeaderTheme.graphite:
        final paint = Paint()
          ..color = line.withValues(alpha: 0.45)
          ..strokeWidth = 1;
        for (var x = size.width * .55; x < size.width + 40; x += 22) {
          canvas.drawLine(Offset(x, 0), Offset(x - 80, size.height), paint);
        }
      case ProfileHeaderTheme.signal:
        final center = Offset(size.width * .84, size.height * .34);
        for (var radius = 22.0; radius <= 88; radius += 22) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            2.2,
            2.6,
            false,
            radius == 66 ? accent : subtle,
          );
        }
    }
  }

  @override
  bool shouldRepaint(covariant _ProfileHeaderBackgroundPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.line != line;
  }
}

class _ProfileProgress extends StatelessWidget {
  const _ProfileProgress({required this.profile});

  final FreelancerProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    const completion = 0.86;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mức độ hoàn thiện hồ sơ',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${(completion * 100).round()}%',
              style: TextStyle(
                color: theme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: completion,
            minHeight: 5,
            color: theme.primary,
            backgroundColor: theme.surfaceSubtle,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Bổ sung chứng chỉ để doanh nghiệp có thêm cơ sở đánh giá.',
          style: TextStyle(color: theme.textSecondary, fontSize: 11.5),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final FreelancerProject project;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.layers_outlined,
                  size: 21,
                  color: theme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.role,
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusTag(label: project.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            project.summary,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final technology in project.technologies)
                _Tag(label: technology),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReputationEntry extends StatelessWidget {
  const _ReputationEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Material(
      color: theme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const ReputationBadge(
                tier: ReputationTier.unranked,
                size: ReputationBadgeSize.compact,
                showLabel: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ReputationTier.unranked.label,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cấp bậc uy tín NIVEX',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({required this.experience});

  final FreelancerExperience experience;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 1, height: 58, color: theme.border),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${experience.organization} · ${experience.period}',
                  style: TextStyle(color: theme.primary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  experience.summary,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_outlined, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kỹ thuật phần mềm',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text('Sinh viên · 2023 - 2027'),
                SizedBox(height: 7),
                Text('Thông tin do người dùng tự khai'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice({required this.visibility});

  final ProfileVisibility visibility;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 20, color: theme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hiển thị: ${visibility.label}',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Email, số điện thoại, tài khoản ngân hàng và địa chỉ ví không xuất hiện trong hồ sơ này.',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfessionalProfileScreen extends StatefulWidget {
  const EditProfessionalProfileScreen({required this.controller, super.key});

  final DemoFreelancerProfileController controller;

  @override
  State<EditProfessionalProfileScreen> createState() =>
      _EditProfessionalProfileScreenState();
}

class _EditProfessionalProfileScreenState
    extends State<EditProfessionalProfileScreen> {
  static const availableSkills = [
    'Flutter',
    'Dart',
    'Java',
    'Spring Boot',
    'PostgreSQL',
    'REST API',
    'Solana',
    'Git',
    'Figma',
    'Automated Testing',
  ];

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  late Set<String> _skills;
  late String? _avatarPath;
  late ProfileHeaderTheme _headerTheme;
  late ProfileVisibility _visibility;
  late bool _isAvailable;
  late double _capacity;

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.profile;
    _headlineController = TextEditingController(text: profile.headline);
    _bioController = TextEditingController(text: profile.bio);
    _skills = profile.skills.toSet();
    _avatarPath = profile.avatarPath;
    _headerTheme = profile.profileHeaderTheme;
    _visibility = profile.visibility;
    _isAvailable = profile.isAvailable;
    _capacity = profile.weeklyCapacityHours.toDouble();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Chỉnh sửa hồ sơ',
      subtitle: 'Thông tin nghề nghiệp công khai',
      showBackButton: true,
      actions: [
        TextButton(onPressed: _save, child: const Text('Lưu')),
        const SizedBox(width: 8),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              key: const Key('edit-profile-list'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const _EditSectionHeading(
                  step: '01',
                  title: 'Ảnh đại diện và nền hồ sơ',
                ),
                const SizedBox(height: 10),
                _AvatarEditor(
                  avatarPath: _avatarPath,
                  onPick: _pickAvatar,
                  onRemove: _avatarPath == null
                      ? null
                      : () => setState(() => _avatarPath = null),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chọn nền thẻ hồ sơ',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _ProfileThemeSelector(
                  selected: _headerTheme,
                  onSelected: (value) => setState(() => _headerTheme = value),
                ),
                const SizedBox(height: 24),
                const _EditSectionHeading(
                  step: '02',
                  title: 'Tiêu đề và giới thiệu',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('profile-headline-field'),
                  controller: _headlineController,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề chuyên môn',
                    hintText: 'Flutter Developer | Fintech Mobile Applications',
                  ),
                  validator: (value) {
                    final length = value?.trim().length ?? 0;
                    if (length < 12) return 'Hãy mô tả chuyên môn rõ hơn';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('profile-bio-field'),
                  controller: _bioController,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: 600,
                  decoration: const InputDecoration(
                    labelText: 'Giới thiệu',
                    alignLabelWithHint: true,
                    hintText:
                        'Bạn làm gì, phù hợp dự án nào và mang lại giá trị gì?',
                  ),
                  validator: (value) {
                    if ((value?.trim().length ?? 0) < 40) {
                      return 'Phần giới thiệu cần ít nhất 40 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const _EditSectionHeading(step: '03', title: 'Kỹ năng'),
                const SizedBox(height: 6),
                Text(
                  'Chọn tối đa 10 kỹ năng phù hợp nhất.',
                  style: TextStyle(color: theme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in availableSkills)
                      FilterChip(
                        label: Text(skill),
                        selected: _skills.contains(skill),
                        onSelected: (selected) {
                          if (selected && _skills.length >= 10) return;
                          setState(() {
                            selected
                                ? _skills.add(skill)
                                : _skills.remove(skill);
                          });
                        },
                      ),
                    for (final skill in _skills.where(
                      (skill) => !availableSkills.contains(skill),
                    ))
                      FilterChip(
                        label: Text(skill),
                        selected: true,
                        onSelected: (_) =>
                            setState(() => _skills.remove(skill)),
                      ),
                    ActionChip(
                      key: const Key('add-custom-skill'),
                      avatar: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Thêm kỹ năng'),
                      onPressed: _showAddSkillDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _EditSectionHeading(
                  step: '04',
                  title: 'Khả năng nhận việc',
                ),
                const SizedBox(height: 10),
                _EditSurface(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Sẵn sàng nhận việc'),
                      subtitle: const Text(
                        'Cho doanh nghiệp biết bạn có thể bắt đầu',
                      ),
                      value: _isAvailable,
                      onChanged: (value) =>
                          setState(() => _isAvailable = value),
                    ),
                    Divider(height: 1, color: theme.divider),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(child: Text('Thời lượng mỗi tuần')),
                        Text(
                          '${_capacity.round()} giờ',
                          style: TextStyle(
                            color: theme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _capacity,
                      min: 5,
                      max: 40,
                      divisions: 7,
                      label: '${_capacity.round()} giờ',
                      onChanged: (value) => setState(() => _capacity = value),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _EditSectionHeading(step: '05', title: 'Quyền riêng tư'),
                const SizedBox(height: 10),
                DropdownButtonFormField<ProfileVisibility>(
                  initialValue: _visibility,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Ai có thể xem hồ sơ',
                    prefixIcon: Icon(Icons.visibility_outlined),
                  ),
                  items: [
                    for (final visibility in ProfileVisibility.values)
                      DropdownMenuItem(
                        value: visibility,
                        child: Text(
                          visibility.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _visibility = value);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Thông tin liên hệ và tài chính luôn được giữ riêng tư.',
                  style: TextStyle(color: theme.textSecondary, fontSize: 11.5),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  key: const Key('save-professional-profile'),
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Lưu hồ sơ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 1200,
      );
      if (image != null && mounted) setState(() => _avatarPath = image.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể mở thư viện ảnh. Hãy kiểm tra quyền truy cập.',
          ),
        ),
      );
    }
  }

  Future<void> _showAddSkillDialog() async {
    if (_skills.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã chọn tối đa 10 kỹ năng')),
      );
      return;
    }
    var pendingSkill = '';
    final skill = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm kỹ năng'),
        content: TextField(
          key: const Key('custom-skill-field'),
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Tên kỹ năng',
            hintText: 'Ví dụ: Biên tập, Bán hàng, Phiên dịch',
          ),
          onChanged: (value) => pendingSkill = value,
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(pendingSkill),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
    final normalized = skill?.trim();
    if (normalized == null || normalized.isEmpty || !mounted) return;
    if (_skills.any((item) => item.toLowerCase() == normalized.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kỹ năng này đã có trong hồ sơ')),
      );
      return;
    }
    setState(() => _skills.add(normalized));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn ít nhất một kỹ năng')),
      );
      return;
    }
    final current = widget.controller.profile;
    widget.controller.update(
      current.copyWith(
        headline: _headlineController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skills.toList(growable: false),
        visibility: _visibility,
        isAvailable: _isAvailable,
        weeklyCapacityHours: _capacity.round(),
        avatarPath: _avatarPath,
        clearAvatar: _avatarPath == null,
        profileHeaderTheme: _headerTheme,
      ),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật hồ sơ nghề nghiệp')),
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({
    required this.avatarPath,
    required this.onPick,
    required this.onRemove,
  });

  final String? avatarPath;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: theme.surfaceSubtle,
            foregroundImage: avatarPath == null
                ? null
                : FileImage(File(avatarPath!)),
            child: avatarPath == null
                ? Icon(
                    Icons.add_a_photo_outlined,
                    color: theme.primary,
                    size: 27,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ảnh đại diện',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ảnh vuông, khuôn mặt rõ và đủ sáng.',
                  style: TextStyle(color: theme.textSecondary, fontSize: 11.5),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('pick-profile-avatar'),
                      onPressed: onPick,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Chọn từ thư viện'),
                    ),
                    if (onRemove != null)
                      IconButton(
                        tooltip: 'Xóa ảnh đại diện',
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileThemeSelector extends StatelessWidget {
  const _ProfileThemeSelector({
    required this.selected,
    required this.onSelected,
  });

  final ProfileHeaderTheme selected;
  final ValueChanged<ProfileHeaderTheme> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return SizedBox(
      height: 88,
      child: ListView.separated(
        key: const Key('profile-theme-list'),
        scrollDirection: Axis.horizontal,
        itemCount: ProfileHeaderTheme.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final option = ProfileHeaderTheme.values[index];
          final isSelected = option == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            label: 'Nền ${option.label}',
            child: InkWell(
              key: Key('profile-theme-${option.name}'),
              onTap: () => onSelected(option),
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: 104,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isSelected ? theme.primary : theme.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ProfileHeaderBackgroundPainter(
                          variant: option,
                          primary: theme.primary,
                          secondary: theme.success,
                          line: theme.border,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 7,
                      child: Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: theme.primary,
                          size: 17,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return NivexCard(padding: padding, child: child);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      children: [
        Icon(icon, size: 19, color: theme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized
            ? theme.primary.withValues(alpha: 0.14)
            : theme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: emphasized
              ? theme.primary.withValues(alpha: 0.65)
              : theme.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: emphasized ? theme.primary : theme.textSecondary,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final color = isAvailable ? theme.success : theme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        isAvailable ? 'Sẵn sàng' : 'Đang bận',
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: theme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: theme.textSecondary, fontSize: 11.5),
        ),
      ],
    );
  }
}

class _WorkMetric extends StatelessWidget {
  const _WorkMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.textSecondary, fontSize: 10.5),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: theme.warningSoft,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.warning,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EditSectionHeading extends StatelessWidget {
  const _EditSectionHeading({required this.step, required this.title});

  final String step;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      children: [
        Text(
          step,
          style: TextStyle(
            color: theme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditSurface extends StatelessWidget {
  const _EditSurface({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return NivexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
