import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/jobs/domain/job_application.dart';
import 'package:nivex_flutter/features/jobs/domain/job_opportunity.dart';

class DemoApplicationController extends ChangeNotifier {
  DemoApplicationController._();

  static final instance = DemoApplicationController._();

  final Map<String, JobApplication> _applications = {
    'job-product-designer': JobApplication(
      id: 'application-demo-product',
      jobId: 'job-product-designer',
      jobTitle: 'Product Designer - Remote Workflows',
      organizationName: 'Nova Labs',
      candidateName: 'Minh Anh',
      candidateHeadline: 'Flutter & Product Developer',
      candidateEmail: 'minh.anh@example.com',
      location: 'TP. Hồ Chí Minh, Việt Nam',
      coverNote: 'Mình muốn đóng góp vào trải nghiệm làm việc và chi trả rõ ràng hơn cho đội ngũ remote.',
      portfolioLabel: 'github.com/minhanh-dev',
      availability: 'Có thể bắt đầu ngay',
      status: JobApplicationStatus.approved,
      submittedAt: DateTime(2026, 9, 10, 11, 8),
      messages: [
        JobApplicationMessage(
          id: 'message-product-system',
          role: JobMessageRole.system,
          senderName: 'Nova',
          body: 'Hồ sơ đã được duyệt. Hai bên có thể tiếp tục trao đổi.',
          sentAt: DateTime(2026, 9, 11, 14, 30),
        ),
        JobApplicationMessage(
          id: 'message-product-business',
          role: JobMessageRole.business,
          senderName: 'Nova Labs',
          body: 'Chào Minh Anh, đội ngũ muốn trao đổi với bạn về quy trình nghiên cứu người dùng cho dự án.',
          sentAt: DateTime(2026, 9, 11, 14, 36),
        ),
      ],
    ),
  };
  final Set<String> _typingApplicationIds = {};
  final Map<String, List<Timer>> _pendingTimers = {};

  List<JobApplication> get applications =>
      List.unmodifiable(_applications.values);

  JobApplication? forJob(String jobId) => _applications[jobId];

  JobApplication? byId(String applicationId) {
    for (final application in _applications.values) {
      if (application.id == applicationId) return application;
    }
    return null;
  }

  bool isBusinessTyping(String applicationId) =>
      _typingApplicationIds.contains(applicationId);

  JobApplication apply(JobOpportunity job) {
    final existing = _applications[job.id];
    if (existing != null) return existing;

    final now = DateTime.now();
    final application = JobApplication(
      id: 'application-${job.id}-${now.millisecondsSinceEpoch}',
      jobId: job.id,
      jobTitle: job.title,
      organizationName: job.organizationName,
      candidateName: 'Minh Anh',
      candidateHeadline: 'Flutter & Product Developer',
      candidateEmail: 'minh.anh@example.com',
      location: 'TP. Hồ Chí Minh, Việt Nam',
      coverNote:
          'Mình quan tâm đến cách ${job.organizationName} xây dựng ${job.title.toLowerCase()} và sẵn sàng trao đổi thêm về kinh nghiệm phù hợp.',
      portfolioLabel: 'github.com/minhanh-dev',
      availability: 'Có thể bắt đầu trong 1 tuần',
      status: JobApplicationStatus.submitted,
      submittedAt: now,
      messages: [
        JobApplicationMessage(
          id: 'message-system-${now.millisecondsSinceEpoch}',
          role: JobMessageRole.system,
          senderName: 'Nova',
          body: 'Hồ sơ đã được gửi đến ${job.organizationName}.',
          sentAt: now,
        ),
        JobApplicationMessage(
          id: 'message-business-${now.millisecondsSinceEpoch}',
          role: JobMessageRole.business,
          senderName: job.organizationName,
          body: 'Đội ngũ đã nhận hồ sơ của bạn. Mọi cập nhật xét duyệt sẽ xuất hiện tại cuộc trò chuyện này.',
          sentAt: now.add(const Duration(minutes: 1)),
        ),
      ],
    );
    _applications[job.id] = application;
    notifyListeners();
    return application;
  }

  void sendTalentMessage(
    String applicationId,
    String body, {
    String? replyToId,
  }) {
    final application = byId(applicationId);
    final normalized = body.trim();
    if (application == null || normalized.isEmpty) return;
    final now = DateTime.now();
    _applications[application.jobId] = application.copyWith(
      messages: [
        ...application.messages,
        JobApplicationMessage(
          id: 'message-talent-${now.millisecondsSinceEpoch}',
          role: JobMessageRole.talent,
          senderName: application.candidateName,
          body: normalized,
          sentAt: now,
          deliveryStatus: JobMessageDeliveryStatus.sending,
          replyToId: replyToId,
        ),
      ],
    );
    notifyListeners();

    _schedule(applicationId, const Duration(milliseconds: 250), () {
      _updateDelivery(
        applicationId,
        'message-talent-${now.millisecondsSinceEpoch}',
        JobMessageDeliveryStatus.sent,
      );
    });
    _schedule(applicationId, const Duration(milliseconds: 550), () {
      _updateDelivery(
        applicationId,
        'message-talent-${now.millisecondsSinceEpoch}',
        JobMessageDeliveryStatus.delivered,
      );
    });
    _schedule(applicationId, const Duration(milliseconds: 850), () {
      _updateDelivery(
        applicationId,
        'message-talent-${now.millisecondsSinceEpoch}',
        JobMessageDeliveryStatus.seen,
      );
      _typingApplicationIds.add(applicationId);
      notifyListeners();
    });
    _schedule(applicationId, const Duration(milliseconds: 2100), () {
      final current = byId(applicationId);
      if (current == null) return;
      _typingApplicationIds.remove(applicationId);
      _applications[current.jobId] = current.copyWith(
        messages: [
          ...current.messages,
          JobApplicationMessage(
            id: 'message-business-reply-${DateTime.now().millisecondsSinceEpoch}',
            role: JobMessageRole.business,
            senderName: current.organizationName,
            body: 'Cảm ơn bạn. Đội ngũ đã nhận tin nhắn và sẽ phản hồi chi tiết trong hồ sơ này.',
            sentAt: DateTime.now(),
            replyToId: 'message-talent-${now.millisecondsSinceEpoch}',
          ),
        ],
      );
      notifyListeners();
    });
  }

  void cancelPendingActivity(String applicationId) {
    for (final timer in _pendingTimers.remove(applicationId) ?? <Timer>[]) {
      timer.cancel();
    }
    if (_typingApplicationIds.remove(applicationId)) notifyListeners();
  }

  void _schedule(String applicationId, Duration delay, VoidCallback callback) {
    final timer = Timer(delay, callback);
    _pendingTimers.putIfAbsent(applicationId, () => []).add(timer);
  }

  void _updateDelivery(
    String applicationId,
    String messageId,
    JobMessageDeliveryStatus status,
  ) {
    final application = byId(applicationId);
    if (application == null) return;
    _applications[application.jobId] = application.copyWith(
      messages: application.messages
          .map(
            (message) => message.id == messageId
                ? message.copyWith(deliveryStatus: status)
                : message,
          )
          .toList(),
    );
    notifyListeners();
  }
}
