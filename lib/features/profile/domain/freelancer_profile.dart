enum ProfileVisibility { public, registeredUsers, connectedUsers, private }

enum ProfileHeaderTheme { flow, horizon, circuit, graphite, signal }

extension ProfileHeaderThemeLabel on ProfileHeaderTheme {
  String get label => switch (this) {
    ProfileHeaderTheme.flow => 'Dòng chảy',
    ProfileHeaderTheme.horizon => 'Chân trời',
    ProfileHeaderTheme.circuit => 'Mạch kết nối',
    ProfileHeaderTheme.graphite => 'Tối giản',
    ProfileHeaderTheme.signal => 'Tín hiệu',
  };
}

extension ProfileVisibilityLabel on ProfileVisibility {
  String get label => switch (this) {
    ProfileVisibility.public => 'Công khai',
    ProfileVisibility.registeredUsers => 'Người dùng NIVEX',
    ProfileVisibility.connectedUsers => 'Doanh nghiệp đã kết nối',
    ProfileVisibility.private => 'Riêng tư',
  };
}

class FreelancerExperience {
  const FreelancerExperience({
    required this.title,
    required this.organization,
    required this.period,
    required this.summary,
  });

  final String title;
  final String organization;
  final String period;
  final String summary;
}

class FreelancerEducation {
  const FreelancerEducation({
    required this.program,
    required this.institution,
    required this.period,
    required this.note,
  });

  final String program;
  final String institution;
  final String period;
  final String note;
}

class FreelancerProject {
  const FreelancerProject({
    required this.title,
    required this.role,
    required this.summary,
    required this.technologies,
    required this.status,
    this.link = '',
  });

  final String title;
  final String role;
  final String summary;
  final List<String> technologies;
  final String status;
  final String link;
}

class FreelancerProfile {
  const FreelancerProfile({
    required this.displayName,
    required this.username,
    required this.headline,
    required this.bio,
    required this.location,
    required this.timezone,
    required this.languages,
    required this.skills,
    required this.experiences,
    required this.education,
    required this.projects,
    required this.visibility,
    required this.isAvailable,
    required this.weeklyCapacityHours,
    required this.workPreference,
    required this.startAvailability,
    required this.profileHeaderTheme,
    this.avatarPath,
  });

  final String displayName;
  final String username;
  final String headline;
  final String bio;
  final String location;
  final String timezone;
  final List<String> languages;
  final List<String> skills;
  final List<FreelancerExperience> experiences;
  final List<FreelancerEducation> education;
  final List<FreelancerProject> projects;
  final ProfileVisibility visibility;
  final bool isAvailable;
  final int weeklyCapacityHours;
  final String workPreference;
  final String startAvailability;
  final ProfileHeaderTheme profileHeaderTheme;
  final String? avatarPath;

  FreelancerProfile copyWith({
    String? headline,
    String? bio,
    List<String>? skills,
    ProfileVisibility? visibility,
    bool? isAvailable,
    int? weeklyCapacityHours,
    String? workPreference,
    String? startAvailability,
    List<FreelancerExperience>? experiences,
    List<FreelancerProject>? projects,
    List<FreelancerEducation>? education,
    ProfileHeaderTheme? profileHeaderTheme,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return FreelancerProfile(
      displayName: displayName,
      username: username,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      location: location,
      timezone: timezone,
      languages: languages,
      skills: skills ?? this.skills,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
      projects: projects ?? this.projects,
      visibility: visibility ?? this.visibility,
      isAvailable: isAvailable ?? this.isAvailable,
      weeklyCapacityHours: weeklyCapacityHours ?? this.weeklyCapacityHours,
      workPreference: workPreference ?? this.workPreference,
      startAvailability: startAvailability ?? this.startAvailability,
      profileHeaderTheme: profileHeaderTheme ?? this.profileHeaderTheme,
      avatarPath: clearAvatar ? null : avatarPath ?? this.avatarPath,
    );
  }
}
