import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/features/profile/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

/// Name, headline and bio are saved with `PATCH /api/v1/profile/me`. Email and
/// phone come from the login account and have no edit contract, so they stay
/// read-only.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _controller = DemoFreelancerProfileController.instance;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _headline;
  late final TextEditingController _bio;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _headline = TextEditingController();
    _bio = TextEditingController();
    _fillFromController();
    _controller.addListener(_onControllerChanged);
    if (_controller.hasBackend && _controller.remoteProfile == null) {
      _controller.refreshRemote();
    }
  }

  void _fillFromController() {
    _name.text = _controller.displayName;
    _headline.text = _controller.profile.headline;
    _bio.text = _controller.profile.bio;
  }

  void _onControllerChanged() {
    if (!mounted) return;
    // A remote profile arriving after the screen opened fills untouched fields.
    if (!_dirty && !_saving) _fillFromController();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _name.dispose();
    _headline.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _controller.saveBasics(
        displayName: _name.text.trim(),
        headline: _headline.text.trim(),
        bio: _bio.text.trim(),
      );
      _dirty = false;
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã lưu thông tin cá nhân')),
      );
    } on NovaApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.requiresLogin
                ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
                : 'Không lưu được (${error.statusCode ?? 'mạng'}). Dữ liệu cũ được giữ nguyên.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final controller = _controller;
    final loading =
        controller.hasBackend &&
        controller.remoteProfile == null &&
        !controller.remoteFailed;
    return NivexPage(
      title: 'Thông tin cá nhân',
      subtitle: controller.hasBackend
          ? 'Tài khoản Nova của bạn'
          : 'Hồ sơ người dùng demo',
      showBackButton: true,
      actions: [
        TextButton(
          key: const Key('personal-info-save'),
          onPressed: _saving || loading || controller.remoteFailed
              ? null
              : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
        const SizedBox(width: 8),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : controller.hasBackend && controller.remoteProfile == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Không tải được hồ sơ từ máy chủ.',
                        style: TextStyle(color: theme.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: controller.isLoadingRemote
                            ? null
                            : controller.refreshRemote,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  onChanged: () => _dirty = true,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: [
                      TextFormField(
                        key: const Key('personal-info-name'),
                        controller: _name,
                        maxLength: 160,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) => (value ?? '').trim().length < 2
                            ? 'Họ tên cần ít nhất 2 ký tự'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('personal-info-headline'),
                        controller: _headline,
                        maxLength: 240,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề nghề nghiệp',
                          prefixIcon: Icon(Icons.work_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('personal-info-bio'),
                        controller: _bio,
                        maxLength: 5000,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Giới thiệu',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.border),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Email',
                              value: controller.email ?? 'Chưa liên kết email',
                              icon: Icons.email_outlined,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: theme.divider,
                            ),
                            _InfoRow(
                              label: 'Số điện thoại',
                              value: controller.phone ?? 'Chưa liên kết',
                              icon: Icons.phone_outlined,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: theme.divider,
                            ),
                            _InfoRow(
                              label: 'Nova ID',
                              value: controller.novaId ?? '—',
                              icon: Icons.badge_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      DemoNotice(
                        text: controller.hasBackend
                            ? 'Email và số điện thoại là thông tin đăng nhập, hiện chưa thể thay đổi trong ứng dụng.'
                            : 'Bản demo không có máy chủ: thay đổi chỉ lưu trên thiết bị này.',
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: theme.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
