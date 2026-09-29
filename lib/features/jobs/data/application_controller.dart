import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/features/jobs/data/demo_application_controller.dart';
import 'package:nivex_flutter/features/jobs/data/remote_application_controller.dart';
import 'package:nivex_flutter/features/jobs/domain/job_application.dart';
import 'package:nivex_flutter/features/jobs/domain/job_opportunity.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';

/// Jobs, applications and conversations shown on the Jobs and Messages tabs.
///
/// With a signed-in [NovaApiClient] the data comes from the shared Nova
/// backend, so Business Web sees the same applications and messages. Without
/// a backend the offline demo fixtures are used.
abstract class ApplicationController extends ChangeNotifier {
  static ApplicationController resolve(NovaApiClient? api) => api == null
      ? DemoApplicationController.instance
      : RemoteApplicationController.of(api);

  List<JobOpportunity> get jobs;
  List<JobApplication> get applications;

  /// One entry per conversation, newest first.
  List<JobApplication> get conversations;

  bool get isLoading => false;
  String? get errorMessage => null;

  JobApplication? forJob(String jobId);
  JobApplication? byId(String applicationId);
  bool isBusinessTyping(String applicationId) => false;

  /// Refreshes the business typing state of an open conversation.
  Future<void> pollTyping(String applicationId) async {}

  /// Tells the business that the talent is typing; throttled by implementations.
  void reportTyping(String applicationId) {}

  Future<void> refresh() async {}

  /// Returns null and sets [errorMessage] when the backend rejects the request.
  Future<JobApplication?> apply(JobOpportunity job);

  Future<bool> withdraw(String applicationId) async => false;

  Future<bool> sendTalentMessage(
    String applicationId,
    String body, {
    String? replyToId,
  });

  /// Records that the talent opened the conversation.
  Future<void> markConversationRead(String applicationId) async {}

  void cancelPendingActivity(String applicationId) {}
}
