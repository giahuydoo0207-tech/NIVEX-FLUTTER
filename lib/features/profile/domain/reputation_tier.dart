enum ReputationTier { unranked, bronze, silver, gold, platinum, verifiedExpert }

extension ReputationTierInfo on ReputationTier {
  String get label => switch (this) {
    ReputationTier.unranked => 'Chưa xếp hạng',
    ReputationTier.bronze => 'Bronze',
    ReputationTier.silver => 'Silver',
    ReputationTier.gold => 'Gold',
    ReputationTier.platinum => 'Platinum',
    ReputationTier.verifiedExpert => 'Xác minh chuyên môn',
  };

  String get shortLabel => switch (this) {
    ReputationTier.unranked => 'Chưa xếp hạng',
    ReputationTier.bronze => 'Bronze',
    ReputationTier.silver => 'Silver',
    ReputationTier.gold => 'Gold',
    ReputationTier.platinum => 'Platinum',
    ReputationTier.verifiedExpert => 'Verified',
  };

  String get requirement => switch (this) {
    ReputationTier.unranked => 'Cần tối thiểu 3 dự án hoặc review hợp lệ',
    ReputationTier.bronze => '60+ điểm · 5 review hợp lệ',
    ReputationTier.silver => '75+ điểm · 12 review hợp lệ',
    ReputationTier.gold => '88+ điểm · 20 review hợp lệ',
    ReputationTier.platinum => '95+ điểm · 35 review hợp lệ',
    ReputationTier.verifiedExpert =>
      'Gold/Platinum + xác minh chuyên môn thủ công',
  };
}
