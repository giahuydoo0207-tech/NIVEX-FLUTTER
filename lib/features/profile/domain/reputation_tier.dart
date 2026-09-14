enum ReputationTier { unranked, bronze, silver, gold, verifiedExpert }

extension ReputationTierInfo on ReputationTier {
  String get label => switch (this) {
    ReputationTier.unranked => 'Chưa xếp hạng',
    ReputationTier.bronze => 'NIVEX Bronze',
    ReputationTier.silver => 'NIVEX Silver',
    ReputationTier.gold => 'NIVEX Gold',
    ReputationTier.verifiedExpert => 'Verified Expert',
  };

  String get shortLabel => switch (this) {
    ReputationTier.unranked => 'Chưa xếp hạng',
    ReputationTier.bronze => 'Bronze',
    ReputationTier.silver => 'Silver',
    ReputationTier.gold => 'Gold',
    ReputationTier.verifiedExpert => 'Expert',
  };

  String get requirement => switch (this) {
    ReputationTier.unranked => 'Cần tối thiểu 3 dự án hoặc review hợp lệ',
    ReputationTier.bronze => '60+ điểm · 5 review hợp lệ',
    ReputationTier.silver => '75+ điểm · 12 review hợp lệ',
    ReputationTier.gold => '88+ điểm · 20 review hợp lệ',
    ReputationTier.verifiedExpert => 'Gold + xác minh chuyên môn thủ công',
  };
}
