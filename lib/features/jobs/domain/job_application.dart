enum JobApplicationStatus { submitted, inReview, approved, rejected }

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

  String get statusLabel => switch (status) {
    JobApplicationStatus.submitted => 'Đã gửi',
    JobApplicationStatus.inReview => 'Đang xem xét',
    JobApplicationStatus.approved => 'Đã duyệt',
    JobApplicationStatus.rejected => 'Đã từ chối',
  };

  String get statusDescription => switch (status) {
    JobApplicationStatus.submitted => 'Doanh nghiệp đã nhận hồ sơ',
    JobApplicationStatus.inReview => 'Đội ngũ đang đánh giá hồ sơ',
    JobApplicationStatus.approved => 'Sẵn sàng trao đổi bước tiếp theo',
    JobApplicationStatus.rejected => 'Quy trình ứng tuyển đã khép lại',
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
    );
  }
}
