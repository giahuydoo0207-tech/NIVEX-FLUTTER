import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/jobs/data/demo_job_opportunities.dart';
import 'package:nivex_flutter/features/jobs/domain/job_opportunity.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

enum _JobFilter { all, matched, saved }

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();
  final _savedIds = <String>{};
  final _appliedIds = <String>{};
  _JobFilter _filter = _JobFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = DemoJobOpportunities.items.where((job) {
      final query = _query.trim().toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          [
            job.title,
            job.category,
            job.organizationName,
            ...job.skills,
          ].join(' ').toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        _JobFilter.all => true,
        _JobFilter.matched => job.matchScore >= 90,
        _JobFilter.saved => _savedIds.contains(job.id),
      };
      return matchesQuery && matchesFilter;
    }).toList();

    return NivexPage(
      title: 'Công việc',
      subtitle: 'Cơ hội remote phù hợp với hồ sơ của bạn',
      actions: [
        _JobAlertButton(count: 2, onPressed: _showAlertSummary),
        const SizedBox(width: 8),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            key: const PageStorageKey('jobs-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
            children: [
              const _JobSignalPanel(),
              const SizedBox(height: 18),
              SearchBar(
                controller: _searchController,
                hintText: 'Tìm vị trí, kỹ năng hoặc tổ chức',
                leading: const Icon(Icons.search_rounded),
                trailing: _query.isEmpty
                    ? null
                    : [
                        IconButton(
                          tooltip: 'Xóa tìm kiếm',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<_JobFilter>(
                  segments: const [
                    ButtonSegment(
                      value: _JobFilter.all,
                      icon: Icon(Icons.grid_view_rounded),
                      label: Text('Tất cả'),
                    ),
                    ButtonSegment(
                      value: _JobFilter.matched,
                      icon: Icon(Icons.auto_awesome_outlined),
                      label: Text('Phù hợp'),
                    ),
                    ButtonSegment(
                      value: _JobFilter.saved,
                      icon: Icon(Icons.bookmark_outline_rounded),
                      label: Text('Đã lưu'),
                    ),
                  ],
                  selected: {_filter},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) {
                    setState(() => _filter = selection.first);
                  },
                ),
              ),
              const SizedBox(height: 22),
              _SectionHeading(resultCount: jobs.length),
              const SizedBox(height: 10),
              if (jobs.isEmpty)
                _EmptyJobs(filter: _filter)
              else
                ...jobs.map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _JobCard(
                      job: job,
                      isSaved: _savedIds.contains(job.id),
                      isApplied: _appliedIds.contains(job.id),
                      onSave: () => _toggleSaved(job.id),
                      onTap: () => _showJob(job),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSaved(String id) {
    setState(() {
      if (!_savedIds.add(id)) _savedIds.remove(id);
    });
  }

  Future<void> _showJob(JobOpportunity job) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _JobDetailSheet(
        job: job,
        initiallyApplied: _appliedIds.contains(job.id),
        onApply: () => _apply(job),
      ),
    );
  }

  Future<void> _apply(JobOpportunity job) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _appliedIds.add(job.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi hồ sơ đến ${job.organizationName}')),
    );
  }

  void _showAlertSummary() {
    final theme = context.nivexTheme;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông báo công việc',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Có 2 cơ hội mới khớp với kỹ năng trong hồ sơ của bạn.',
              style: TextStyle(color: theme.textSecondary),
            ),
            const SizedBox(height: 12),
            for (final job in DemoJobOpportunities.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.work_outline_rounded, color: theme.primary),
                title: Text(
                  job.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${job.matchScore}% phù hợp • ${job.publishedLabel}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).pop();
                  _showJob(job);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _JobSignalPanel extends StatelessWidget {
  const _JobSignalPanel();

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 142),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SignalPainter(
                  color: theme.primary.withValues(alpha: 0.22),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.primary.withValues(alpha: 0.42),
                    ),
                  ),
                  child: Icon(
                    Icons.radar_rounded,
                    color: theme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tín hiệu việc làm',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '2 cơ hội mới vừa khớp với hồ sơ Flutter và Product Design.',
                        style: TextStyle(
                          color: theme.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'CẬP NHẬT 2 PHÚT TRƯỚC',
                        style: TextStyle(
                          color: theme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _SignalPainter extends CustomPainter {
  const _SignalPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.58, 0)
      ..lineTo(size.width * 0.72, size.height * 0.42)
      ..lineTo(size.width, size.height * 0.42);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.42), 4, paint);
    canvas.drawLine(
      Offset(size.width * 0.82, size.height),
      Offset(size.width * 0.82, size.height * 0.72),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SignalPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.resultCount});

  final int resultCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Dành cho bạn',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Text(
          '$resultCount kết quả',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isSaved,
    required this.isApplied,
    required this.onSave,
    required this.onTap,
  });

  final JobOpportunity job;
  final bool isSaved;
  final bool isApplied;
  final VoidCallback onSave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Material(
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.border),
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      color: theme.primary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                job.organizationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (job.organizationVerified) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified_rounded,
                                color: theme.primary,
                                size: 15,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontSize: 16, height: 1.28),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isSaved ? 'Bỏ lưu' : 'Lưu công việc',
                    onPressed: onSave,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: isSaved ? theme.primary : theme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                job.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final skill in job.skills) _SkillTag(label: skill),
                ],
              ),
              const SizedBox(height: 15),
              Divider(color: theme.divider, height: 1),
              const SizedBox(height: 13),
              Row(
                children: [
                  Icon(Icons.payments_outlined, color: theme.primary, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job.budgetLabel,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusLabel(
                    icon: isApplied
                        ? Icons.check_circle_outline_rounded
                        : Icons.auto_awesome_outlined,
                    label: isApplied
                        ? 'Đã ứng tuyển'
                        : '${job.matchScore}% phù hợp',
                    color: isApplied ? theme.success : theme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.public_rounded,
                    color: theme.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Remote • ${job.locationScope} • ${job.engagementLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    job.publishedLabel,
                    style: TextStyle(color: theme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillTag extends StatelessWidget {
  const _SkillTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  const _EmptyJobs({required this.filter});

  final _JobFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
          Icon(
            filter == _JobFilter.saved
                ? Icons.bookmark_outline_rounded
                : Icons.search_off_rounded,
            color: theme.textSecondary,
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            filter == _JobFilter.saved
                ? 'Chưa có công việc đã lưu'
                : 'Không tìm thấy công việc',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            filter == _JobFilter.saved
                ? 'Nhấn biểu tượng lưu trên một cơ hội để xem lại tại đây.'
                : 'Thử đổi từ khóa hoặc chọn bộ lọc khác.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _JobAlertButton extends StatelessWidget {
  const _JobAlertButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return IconButton(
      tooltip: 'Thông báo công việc',
      onPressed: onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded),
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.background, width: 1.5),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: theme.isDark ? const Color(0xFF07101F) : Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobDetailSheet extends StatefulWidget {
  const _JobDetailSheet({
    required this.job,
    required this.initiallyApplied,
    required this.onApply,
  });

  final JobOpportunity job;
  final bool initiallyApplied;
  final Future<void> Function() onApply;

  @override
  State<_JobDetailSheet> createState() => _JobDetailSheetState();
}

class _JobDetailSheetState extends State<_JobDetailSheet> {
  late bool _applied = widget.initiallyApplied;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final job = widget.job;
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                job.organizationName,
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (job.organizationVerified) ...[
                              const SizedBox(width: 5),
                              Icon(
                                Icons.verified_rounded,
                                color: theme.primary,
                                size: 17,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 14),
                  _StatusLabel(
                    icon: Icons.auto_awesome_outlined,
                    label: '${job.matchScore}% phù hợp với hồ sơ',
                    color: theme.primary,
                  ),
                  const SizedBox(height: 22),
                  _DetailMetrics(job: job),
                  const SizedBox(height: 24),
                  Text(
                    'Mô tả công việc',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.summary,
                    style: TextStyle(color: theme.textSecondary, height: 1.55),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Kỹ năng cần có',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final skill in job.skills) _SkillTag(label: skill),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: theme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            'Tổ chức đã xác minh. Thanh toán dự kiến bằng USDC qua NIVEX.',
                            style: TextStyle(
                              color: theme.textSecondary,
                              height: 1.4,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              14 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(top: BorderSide(color: theme.border)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _applied || _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _applied
                            ? Icons.check_circle_outline_rounded
                            : Icons.send_outlined,
                      ),
                label: Text(_applied ? 'Đã gửi hồ sơ' : 'Ứng tuyển ngay'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await widget.onApply();
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _applied = true;
    });
  }
}

class _DetailMetrics extends StatelessWidget {
  const _DetailMetrics({required this.job});

  final JobOpportunity job;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: theme.border)),
      ),
      child: Column(
        children: [
          _MetricRow(
            icon: Icons.payments_outlined,
            label: 'Ngân sách',
            value: job.budgetLabel,
          ),
          Divider(height: 1, color: theme.divider),
          _MetricRow(
            icon: Icons.schedule_outlined,
            label: 'Thời lượng',
            value: job.duration,
          ),
          Divider(height: 1, color: theme.divider),
          _MetricRow(
            icon: Icons.event_outlined,
            label: 'Hạn ứng tuyển',
            value: job.applicationDeadline,
          ),
          Divider(height: 1, color: theme.divider),
          _MetricRow(
            icon: Icons.account_tree_outlined,
            label: 'Hình thức',
            value: '${job.engagementLabel} • ${job.paymentLabel}',
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: theme.primary, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
