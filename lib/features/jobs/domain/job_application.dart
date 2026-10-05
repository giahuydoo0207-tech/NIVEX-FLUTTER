import 'package:nivex_flutter/features/replyn_proposals/domain/replyn_proposal.dart';

/// Mirrors the backend `job_applications.status` values shared with Business Web.
enum JobApplicationStatus {
  submitted,
  viewed,
  shortlisted,
  interview,
  accepted,
  rejected,
  withdrawn;

  static JobApplicationStatus fromApi(String value) =>
      JobApplicationStatus.values.firstWhere(
        (status) => status.name == value.toLowerCase(),
        orElse: () => JobApplicationStatus.submitted,
      );
}

enum JobMessageRole { talent, business, system }

enum JobMessageDeliveryStatus { sending, sent, delivered, seen }

class JobApplicationMessage {
  const JobApplicationMessage({
    required this.id,
    required this.role,
    required this.senderName,
    required this.body,
    required this.sentAt,
    this.deliveryStatus = JobMessageDeliveryStatus.seen,
    this.replyToId,
  });

  final String id;
  final JobMessageRole role;
  final String senderName;
  final String body;
  final DateTime sentAt;
  final JobMessageDeliveryStatus deliveryStatus;
  final String? replyToId;

  JobApplicationMessage copyWith({JobMessageDeliveryStatus? deliveryStatus}) {
    return JobApplicationMessage(
      id: id,
      role: role,
      senderName: senderName,
      body: body,
      sentAt: sentAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      replyToId: replyToId,
    );
  }
}

class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.organizationName,
    required this.candidateName,
    required this.candidateHeadline,
    required this.candidateEmail,
    required this.location,
    required this.coverNote,
    required this.portfolioLabel,
    required this.availability,
    required this.status,
    required this.submittedAt,
    required this.messages,
    this.threadId,
    this.threadStatus,
    this.replynProposals = const [],
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String organizationName;
  final String candidateName;
  final String candidateHeadline;
  final String candidateEmail;
  final String location;
  final String coverNote;
  final String portfolioLabel;
  final String availability;
  final JobApplicationStatus status;
  final DateTime submittedAt;
  final List<JobApplicationMessage> messages;

  /// Backend message thread with the organization, when one exists.
  final String? threadId;

  /// `PENDING`, `ACCEPTED` or `BLOCKED` for backend threads; null in the offline demo.
  final String? threadStatus;

  /// Replyn proposals the business sent in this conversation, oldest first.
  final List<ReplynProposal> replynProposals;

  bool get canWithdraw => const {
    JobApplicationStatus.submitted,
    JobApplicationStatus.viewed,
    JobApplicationStatus.shortlisted,
  }.contains(status);

  String get statusLabel => switch (status) {
    JobApplicationStatus.submitted => 'Đã gửi',
    JobApplicationStatus.viewed => 'Đã xem',
    JobApplicationStatus.shortlisted => 'Đã chọn',
    JobApplicationStatus.interview => 'Phỏng vấn',
    JobApplicationStatus.accepted => 'Đã nhận',
    JobApplicationStatus.rejected => 'Đã từ chối',
    JobApplicationStatus.withdrawn => 'Đã rút',
  };

  String get statusDescription => switch (status) {
    JobApplicationStatus.submitted => 'Doanh nghiệp đã nhận hồ sơ',
    JobApplicationStatus.viewed => 'Doanh nghiệp đã xem hồ sơ',
    JobApplicationStatus.shortlisted => 'Hồ sơ nằm trong danh sách được chọn',
    JobApplicationStatus.interview => 'Doanh nghiệp mời bạn phỏng vấn',
    JobApplicationStatus.accepted => 'Sẵn sàng trao đổi bước tiếp theo',
    JobApplicationStatus.rejected => 'Quy trình ứng tuyển đã khép lại',
    JobApplicationStatus.withdrawn => 'Bạn đã rút hồ sơ này',
  };

  JobApplication copyWith({
    JobApplicationStatus? status,
    List<JobApplicationMessage>? messages,
  }) {
    return JobApplication(
      id: id,
      jobId: jobId,
      jobTitle: jobTitle,
      organizationName: organizationName,
      candidateName: candidateName,
      candidateHeadline: candidateHeadline,
      candidateEmail: candidateEmail,
      location: location,
      coverNote: coverNote,
      portfolioLabel: portfolioLabel,
      availability: availability,
      status: status ?? this.status,
      submittedAt: submittedAt,
      messages: messages ?? this.messages,
      threadId: threadId,
      threadStatus: threadStatus,
      replynProposals: replynProposals,
    );
  }
}
