/// A Replyn proposal a business sent in a Nova conversation. The talent
/// accepts or rejects it in Nova Mobile; only an accepted proposal has a
/// Replyn workspace. Money is simulated: nothing is funded or held.
enum ReplynProposalStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  expired;

  static ReplynProposalStatus? fromApi(Object? value) => switch (value) {
    'PENDING' => pending,
    'ACCEPTED' => accepted,
    'REJECTED' => rejected,
    'CANCELLED' => cancelled,
    'EXPIRED' => expired,
    _ => null,
  };
}

class ReplynMilestone {
  const ReplynMilestone({
    required this.title,
    required this.amount,
    required this.deadline,
  });

  final String title;
  final double? amount;
  final DateTime? deadline;
}

class ReplynProposal {
  const ReplynProposal({
    required this.id,
    required this.threadId,
    required this.status,
    required this.projectName,
    required this.scope,
    required this.deliverables,
    required this.revisionLimit,
    required this.currency,
    required this.totalAmount,
    required this.startDate,
    required this.deadline,
    required this.reviewPeriodDays,
    required this.milestones,
    required this.notes,
    required this.sentAt,
    required this.expiresAt,
    this.workspaceId,
    this.rejectionReason,
  });

  /// Null for anything the talent must not see (drafts) or cannot read.
  static ReplynProposal? tryParse(Object? json) {
    if (json is! Map) return null;
    final status = ReplynProposalStatus.fromApi(json['status']);
    final id = json['id'];
    final threadId = json['threadId'];
    final sentAt = _date(json['sentAt']);
    if (status == null ||
        id is! String ||
        threadId is! String ||
        sentAt == null) {
      return null;
    }
    return ReplynProposal(
      id: id,
      threadId: threadId,
      status: status,
      projectName: _text(json['projectName']),
      scope: _text(json['scope']),
      deliverables: [
        for (final item
            in json['deliverables'] is List
                ? json['deliverables'] as List
                : const [])
          if (item is String && item.trim().isNotEmpty) item,
      ],
      revisionLimit: json['revisionLimit'] is int
          ? json['revisionLimit'] as int
          : null,
      // No silent 'USDC' default: an amount without a known unit shows as '—'.
      currency:
          json['currency'] is String &&
              (json['currency'] as String).trim().isNotEmpty
          ? (json['currency'] as String).trim()
          : null,
      totalAmount: _number(json['totalAmount']),
      startDate: _date(json['startDate']),
      deadline: _date(json['deadline']),
      reviewPeriodDays: json['reviewPeriodDays'] is int
          ? json['reviewPeriodDays'] as int
          : null,
      milestones: [
        for (final item
            in json['milestones'] is List
                ? json['milestones'] as List
                : const [])
          if (item is Map)
            ReplynMilestone(
              title: _text(item['title']),
              amount: _number(item['amount']),
              deadline: _date(item['deadline']),
            ),
      ],
      notes: _text(json['notes']),
      sentAt: sentAt,
      expiresAt: _date(json['expiresAt']),
      workspaceId: json['workspaceId'] is String
          ? json['workspaceId'] as String
          : null,
      rejectionReason: json['rejectionReason'] is String
          ? json['rejectionReason'] as String
          : null,
    );
  }

  final String id;
  final String threadId;
  final ReplynProposalStatus status;
  final String projectName;
  final String scope;
  final List<String> deliverables;
  final int? revisionLimit;
  final String? currency;
  final double? totalAmount;
  final DateTime? startDate;
  final DateTime? deadline;
  final int? reviewPeriodDays;
  final List<ReplynMilestone> milestones;
  final String notes;
  final DateTime sentAt;
  final DateTime? expiresAt;
  final String? workspaceId;
  final String? rejectionReason;

  bool get awaitingTalent => status == ReplynProposalStatus.pending;

  /// Status as the talent reads it on the card.
  String get talentStatusLabel => switch (status) {
    ReplynProposalStatus.pending => 'Chờ bạn xác nhận',
    ReplynProposalStatus.accepted => 'Đã chấp nhận · Mở Replyn',
    ReplynProposalStatus.rejected => 'Đã từ chối',
    ReplynProposalStatus.cancelled => 'Doanh nghiệp đã hủy',
    ReplynProposalStatus.expired => 'Đã hết hạn',
  };

  static const simulationNotice =
      'Cấp vốn, giải ngân và phí hiện đang được mô phỏng. Nova và Replyn chưa giữ tiền thật.';

  static String _text(Object? value) => value is String ? value : '';

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : null;

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}

/// Opaque link to the accepted workspace on Replyn; carries no name, email or amount.
Uri replynWorkspaceUri(String host, String workspaceId) =>
    Uri.https(host, '/workspace/${Uri.encodeComponent(workspaceId)}');
