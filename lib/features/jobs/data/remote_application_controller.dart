import 'dart:async';

import 'package:nivex_flutter/features/jobs/data/application_controller.dart';
import 'package:nivex_flutter/features/jobs/domain/job_application.dart';
import 'package:nivex_flutter/features/jobs/domain/job_opportunity.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

/// Jobs, applications and message threads backed by the shared Nova API.
class RemoteApplicationController extends ApplicationController {
  RemoteApplicationController._(this._api);

  static final _instances = Expando<RemoteApplicationController>();

  /// One controller per API client so Jobs, Messages and the thread screen
  /// share state and requests.
  static RemoteApplicationController of(NovaApiClient api) =>
      _instances[api] ??= RemoteApplicationController._(api);

  final NovaApiClient _api;
  List<NovaJob> _jobs = const [];
  List<NovaJobApplication> _applications = const [];
  List<NovaMessageThread> _threads = const [];
  final List<JobApplicationMessage> _pendingMessages = [];
  bool _isLoading = false;
  String? _errorMessage;
  Future<void>? _refreshInFlight;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  List<JobOpportunity> get jobs =>
      _jobs.map(_toOpportunity).toList(growable: false);

  @override
  List<JobApplication> get applications =>
      _applications.map(_toApplication).toList(growable: false);

  @override
  List<JobApplication> get conversations {
    final items = <JobApplication>[];
    final threadOrganizations = <String>{};
    for (final thread in _threads) {
      threadOrganizations.add(thread.organizationName);
      final latest = _latestApplicationFor(thread.organizationName);
      items.add(
        latest == null ? _threadConversation(thread) : _toApplication(latest),
      );
    }
    for (final application in _applications) {
      if (threadOrganizations.add(application.organizationName)) {
        items.add(_toApplication(application));
      }
    }
    items.sort((a, b) => _lastActivity(b).compareTo(_lastActivity(a)));
    return items;
  }

  @override
  JobApplication? forJob(String jobId) {
    for (final application in _applications) {
      if (application.jobId == jobId) return _toApplication(application);
    }
    return null;
  }

  @override
  JobApplication? byId(String applicationId) {
    for (final application in _applications) {
      if (application.id == applicationId) return _toApplication(application);
    }
    for (final thread in _threads) {
      if (_threadConversationId(thread) == applicationId) {
        return _threadConversation(thread);
      }
    }
    return null;
  }

  @override
  Future<void> refresh() =>
      _refreshInFlight ??= _load().whenComplete(() => _refreshInFlight = null);

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        _api.jobs(),
        _api.myApplications(),
        _api.messageThreads(),
      ]);
      _jobs = results[0] as List<NovaJob>;
      _applications = results[1] as List<NovaJobApplication>;
      _threads = results[2] as List<NovaMessageThread>;
      _errorMessage = null;
    } on NovaApiException catch (error) {
      _errorMessage = _message(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<JobApplication?> apply(JobOpportunity job) async {
    try {
      final created = await _api.submitApplication(
        jobId: job.id,
        coverNote:
            'Mình quan tâm đến vị trí ${job.title} tại ${job.organizationName} '
            'và sẵn sàng trao đổi thêm về kinh nghiệm phù hợp.',
      );
      _applications = [
        created,
        ..._applications.where((a) => a.id != created.id),
      ];
      _errorMessage = null;
      notifyListeners();
      return _toApplication(created);
    } on NovaApiException catch (error) {
      _errorMessage = error.statusCode == 409
          ? 'Công việc không còn nhận hồ sơ hoặc bạn đã ứng tuyển.'
          : _message(error);
      notifyListeners();
      return null;
    }
  }

  @override
  Future<bool> withdraw(String applicationId) async {
    try {
      final updated = await _api.withdrawApplication(applicationId);
      _applications = [
        for (final application in _applications)
          application.id == updated.id ? updated : application,
      ];
      _errorMessage = null;
      notifyListeners();
      return true;
    } on NovaApiException catch (error) {
      _errorMessage = error.statusCode == 409
          ? 'Hồ sơ đã qua bước có thể rút.'
          : _message(error);
      notifyListeners();
      return false;
    }
  }

  @override
  Future<bool> sendTalentMessage(
    String applicationId,
    String body, {
    String? replyToId,
  }) async {
    final text = body.trim();
    final conversation = byId(applicationId);
    if (conversation == null || text.isEmpty) return false;
    final pending = JobApplicationMessage(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      role: JobMessageRole.talent,
      senderName: conversation.candidateName,
      body: text,
      sentAt: DateTime.now(),
      deliveryStatus: JobMessageDeliveryStatus.sending,
      replyToId: replyToId,
    );
    _pendingMessages.add(pending);
    notifyListeners();
    try {
      final threadId = conversation.threadId;
      if (threadId != null && conversation.threadStatus == 'ACCEPTED') {
        await _api.sendThreadMessage(threadId, text);
      } else {
        // A new or still pending conversation is a message request that the
        // business must accept before a regular chat starts.
        await _api.requestConversation(text);
      }
      _threads = await _api.messageThreads();
      _errorMessage = null;
      return true;
    } on NovaApiException catch (error) {
      _errorMessage = switch (error.statusCode) {
        403 => 'Doanh nghiệp không nhận tin nhắn từ bạn.',
        409 => 'Doanh nghiệp chưa chấp nhận yêu cầu trò chuyện.',
        _ => _message(error),
      };
      return false;
    } finally {
      _pendingMessages.remove(pending);
      notifyListeners();
    }
  }

  @override
  Future<void> markConversationRead(String applicationId) async {
    final conversation = byId(applicationId);
    final threadId = conversation?.threadId;
    if (threadId == null) return;
    final thread = _threads.where((t) => t.id == threadId).firstOrNull;
    if (thread == null || thread.unreadForTalent == 0) return;
    try {
      final updated = await _api.markThreadRead(threadId);
      _threads = [
        for (final item in _threads) item.id == updated.id ? updated : item,
      ];
      notifyListeners();
    } on NovaApiException {
      // Seen state is retried the next time the conversation opens.
    }
  }

  @override
  Future<String?> respondToProposal(
    String applicationId,
    String proposalId, {
    required bool accept,
    String? reason,
  }) async {
    final threadId = byId(applicationId)?.threadId;
    if (threadId == null) return 'Không tìm thấy cuộc trò chuyện.';
    try {
      if (accept) {
        await _api.acceptReplynProposal(threadId, proposalId);
      } else {
        await _api.rejectReplynProposal(threadId, proposalId, reason: reason);
      }
      return null;
    } on NovaApiException catch (error) {
      return switch (error.statusCode) {
        409 => 'Đề xuất đã được phản hồi hoặc đã bị hủy.',
        410 => 'Đề xuất đã hết hạn.',
        403 => 'Bạn không thể phản hồi đề xuất này.',
        404 => 'Không tìm thấy đề xuất.',
        _ => _message(error),
      };
    } finally {
      // Both parties' cards follow the backend state, also after a refusal.
      await refresh();
    }
  }

  final Set<String> _typingThreads = {};
  final Map<String, DateTime> _lastTypingReport = {};

  @override
  bool isBusinessTyping(String applicationId) {
    final threadId = byId(applicationId)?.threadId;
    return threadId != null && _typingThreads.contains(threadId);
  }

  @override
  Future<void> pollTyping(String applicationId) async {
    final conversation = byId(applicationId);
    final threadId = conversation?.threadId;
    if (threadId == null || conversation?.threadStatus != 'ACCEPTED') return;
    try {
      final typing = await _api.businessTyping(threadId);
      final wasTyping = _typingThreads.contains(threadId);
      if (typing == wasTyping) return;
      typing ? _typingThreads.add(threadId) : _typingThreads.remove(threadId);
      notifyListeners();
      // Typing usually stops because the message was just sent.
      if (wasTyping && !typing) await refresh();
    } on NovaApiException {
      // The indicator is best-effort; the next poll retries.
    }
  }

  @override
  void reportTyping(String applicationId) {
    final conversation = byId(applicationId);
    final threadId = conversation?.threadId;
    if (threadId == null || conversation?.threadStatus != 'ACCEPTED') return;
    final now = DateTime.now();
    final last = _lastTypingReport[threadId];
    if (last != null && now.difference(last) < const Duration(seconds: 3)) {
      return;
    }
    _lastTypingReport[threadId] = now;
    unawaited(_api.reportTyping(threadId).catchError((Object _) {}));
  }

  @override
  void cancelPendingActivity(String applicationId) {
    // Called from dispose; the tree is locked, so no listeners are notified.
    final threadId = byId(applicationId)?.threadId;
    if (threadId != null) _typingThreads.remove(threadId);
  }

  /// Unread business messages across all conversations.
  int get unreadCount =>
      _threads.fold(0, (total, thread) => total + thread.unreadForTalent);

  NovaJobApplication? _latestApplicationFor(String organizationName) {
    NovaJobApplication? latest;
    for (final application in _applications) {
      if (application.organizationName != organizationName) continue;
      if (latest == null || application.updatedAt.isAfter(latest.updatedAt)) {
        latest = application;
      }
    }
    return latest;
  }

  NovaMessageThread? _threadFor(String organizationName) {
    for (final thread in _threads) {
      if (thread.organizationName == organizationName) return thread;
    }
    return null;
  }

  JobApplication _toApplication(NovaJobApplication application) {
    final thread = _threadFor(application.organizationName);
    return JobApplication(
      id: application.id,
      jobId: application.jobId,
      jobTitle: application.jobTitle,
      organizationName: application.organizationName,
      candidateName: application.candidateName,
      candidateHeadline: application.headline,
      candidateEmail: application.email,
      location: application.location,
      coverNote: application.coverNote,
      portfolioLabel: '',
      availability: '',
      status: JobApplicationStatus.fromApi(application.status),
      submittedAt: application.submittedAt,
      messages: _messages(
        thread,
        application.organizationName,
        application.candidateName,
        systemNote: JobApplicationMessage(
          id: 'system-${application.id}',
          role: JobMessageRole.system,
          senderName: 'Nova',
          body:
              'Hồ sơ "${application.jobTitle}" đã được gửi đến '
              '${application.organizationName}.',
          sentAt: application.submittedAt,
        ),
      ),
      threadId: thread?.id,
      threadStatus: thread?.requestStatus,
      replynProposals: thread?.replynProposals ?? const [],
    );
  }

  String _threadConversationId(NovaMessageThread thread) =>
      'thread-${thread.id}';

  JobApplication _threadConversation(NovaMessageThread thread) {
    return JobApplication(
      id: _threadConversationId(thread),
      jobId: '',
      jobTitle: 'Trò chuyện trực tiếp',
      organizationName: thread.organizationName,
      candidateName: thread.candidateName,
      candidateHeadline: '',
      candidateEmail: '',
      location: '',
      coverNote: '',
      portfolioLabel: '',
      availability: '',
      status: JobApplicationStatus.submitted,
      submittedAt: thread.updatedAt,
      messages: _messages(
        thread,
        thread.organizationName,
        thread.candidateName,
      ),
      threadId: thread.id,
      threadStatus: thread.requestStatus,
      replynProposals: thread.replynProposals,
    );
  }

  List<JobApplicationMessage> _messages(
    NovaMessageThread? thread,
    String organizationName,
    String candidateName, {
    JobApplicationMessage? systemNote,
  }) {
    final messages = <JobApplicationMessage>[?systemNote];
    for (final message in thread?.messages ?? const <NovaThreadMessage>[]) {
      final fromBusiness = message.senderType == 'BUSINESS';
      messages.add(
        JobApplicationMessage(
          id: message.id,
          role: fromBusiness ? JobMessageRole.business : JobMessageRole.talent,
          senderName: fromBusiness ? organizationName : candidateName,
          body: message.body,
          sentAt: message.sentAt.toLocal(),
          deliveryStatus: message.seenAt != null
              ? JobMessageDeliveryStatus.seen
              : message.deliveredAt != null
              ? JobMessageDeliveryStatus.delivered
              : JobMessageDeliveryStatus.sent,
        ),
      );
    }
    if (thread?.requestStatus == 'PENDING') {
      messages.add(
        JobApplicationMessage(
          id: 'pending-request-${thread!.id}',
          role: JobMessageRole.system,
          senderName: 'Nova',
          body: 'Yêu cầu trò chuyện đang chờ $organizationName chấp nhận.',
          sentAt: thread.updatedAt.toLocal(),
        ),
      );
    }
    messages.addAll(_pendingMessages);
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  DateTime _lastActivity(JobApplication application) =>
      application.messages.isEmpty
      ? application.submittedAt
      : application.messages.last.sentAt;

  JobOpportunity _toOpportunity(NovaJob job) {
    final profileSkills = DemoFreelancerProfileController
        .instance
        .profile
        .skills
        .map((skill) => skill.toLowerCase())
        .toSet();
    final matched = job.skills
        .where((skill) => profileSkills.contains(skill.toLowerCase()))
        .length;
    final published = job.publishedAt ?? job.createdAt;
    return JobOpportunity(
      id: job.id,
      organizationName: job.organizationName,
      organizationVerified: true,
      title: job.title,
      category: job.category,
      summary: job.summary,
      skills: job.skills,
      locationScope: job.locationScope,
      engagement: switch (job.engagement) {
        'CONTRACT' => JobEngagement.contract,
        'PART_TIME' => JobEngagement.partTime,
        _ => JobEngagement.project,
      },
      paymentType: switch (job.paymentType) {
        'MILESTONE' => JobPaymentType.milestone,
        'HOURLY' => JobPaymentType.hourly,
        _ => JobPaymentType.fixed,
      },
      budgetMinUsdc: job.budgetMinMinor ~/ 1000000,
      budgetMaxUsdc: job.budgetMaxMinor ~/ 1000000,
      duration: job.duration.isEmpty ? 'Theo thỏa thuận' : job.duration,
      applicationDeadline:
          '${_two(job.applicationDeadline.day)}/${_two(job.applicationDeadline.month)}/${job.applicationDeadline.year}',
      publishedLabel: _relative(published),
      matchScore: job.skills.isEmpty
          ? 0
          : (matched * 100 / job.skills.length).round(),
      isNew: DateTime.now().difference(published).inDays < 2,
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _relative(DateTime time) {
    final elapsed = DateTime.now().difference(time);
    if (elapsed.inMinutes < 1) return 'Vừa xong';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes} phút trước';
    if (elapsed.inDays < 1) return '${elapsed.inHours} giờ trước';
    return '${elapsed.inDays} ngày trước';
  }

  static String _message(NovaApiException error) => switch (error.code) {
    'connection' => 'Không thể kết nối máy chủ Nova.',
    'timeout' => 'Máy chủ phản hồi quá lâu. Hãy thử lại.',
    'unauthorized' => 'Phiên đăng nhập đã hết hạn.',
    _ => 'Không thể đồng bộ với máy chủ Nova.',
  };
}
