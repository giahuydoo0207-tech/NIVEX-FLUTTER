import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/shared/widgets/demo_notice.dart';
import 'package:nivex_flutter/shared/widgets/solana_mark.dart';

class EducationStepItem {
  const EducationStepItem({
    required this.label,
    this.icon,
    this.isSolana = false,
    this.isBlockchain = false,
  });

  final String label;
  final IconData? icon;
  final bool isSolana;
  final bool isBlockchain;
}

class EducationTopic {
  const EducationTopic({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.definition,
    required this.steps,
    required this.howItWorks,
    required this.keyNotes,
    required this.practicalExample,
    this.isScenario = false,
    this.scenarioSteps = const [],
    this.disclaimer,
  });

  final String id;
  final String title;
  final String shortDescription;
  final String definition;
  final List<EducationStepItem> steps;
  final List<String> howItWorks;
  final List<String> keyNotes;
  final String practicalExample;
  final bool isScenario;
  final List<String> scenarioSteps;
  final String? disclaimer;
}

class EducationAnimationTimeline {
  const EducationAnimationTimeline(this.progress);

  final double progress;

  // 1. Node 1: 0 - 15%
  double get node1Opacity =>
      Curves.easeInOutCubic.transform((progress / 0.15).clamp(0.0, 1.0));
  double get node1Scale => 0.94 + 0.06 * node1Opacity;

  // 2. Line 1: 15 - 35%
  double get line1Progress => Curves.easeInOutCubic.transform(
    ((progress - 0.15) / 0.20).clamp(0.0, 1.0),
  );

  // 3. Node 2: 35 - 50%
  double get node2Opacity => Curves.easeInOutCubic.transform(
    ((progress - 0.35) / 0.15).clamp(0.0, 1.0),
  );
  double get node2Scale => 0.94 + 0.06 * node2Opacity;

  // 4. Line 2: 50 - 70%
  double get line2Progress => Curves.easeInOutCubic.transform(
    ((progress - 0.50) / 0.20).clamp(0.0, 1.0),
  );

  // 5. Node 3 / End: 70 - 85%
  double get node3Opacity => Curves.easeInOutCubic.transform(
    ((progress - 0.70) / 0.15).clamp(0.0, 1.0),
  );
  double get node3Scale => 0.94 + 0.06 * node3Opacity;

  // 6. Completion Badge / Checkmark / Ring: 85 - 95%
  double get completionOpacity => Curves.easeInOutCubic.transform(
    ((progress - 0.85) / 0.10).clamp(0.0, 1.0),
  );
  double get completionScale => 0.80 + 0.20 * completionOpacity;

  // 7. 95 - 100%: Hold final state
}

class NivexEducationSection extends StatefulWidget {
  const NivexEducationSection({
    this.initialPage = 0,
    this.initialOpenDetail = false,
    super.key,
  });

  final int initialPage;
  final bool initialOpenDetail;

  static const topics = [
    // 1. NIVEX hoạt động thế nào?
    EducationTopic(
      id: 'nivex_flow',
      title: 'NIVEX hoạt động thế nào?',
      shortDescription: 'NIVEX mô phỏng cách freelancer nhận USDC, xem tỷ giá/phí và theo dõi yêu cầu rút VND trong một giao diện tiếng Việt.',
      definition: 'NIVEX là prototype giúp người dùng làm quen với một quy trình thanh toán quốc tế bằng dữ liệu mô phỏng và Solana Devnet.',
      steps: [
        EducationStepItem(label: 'Bên gửi', icon: Icons.public_rounded),
        EducationStepItem(
          label: 'USDC Devnet',
          icon: Icons.attach_money_rounded,
        ),
        EducationStepItem(
          label: 'Ví NIVEX',
          icon: Icons.currency_exchange_rounded,
        ),
        EducationStepItem(
          label: 'VND demo',
          icon: Icons.account_balance_outlined,
        ),
      ],
      howItWorks: [
        'Người gửi tạo khoản thanh toán.',
        'USDC được gửi qua Solana Devnet hoặc dùng dữ liệu mô phỏng.',
        'NIVEX hiển thị số dư demo.',
        'Người dùng xem tỷ giá, phí và số VND dự kiến nhận.',
        'Payout VND được mô phỏng.',
      ],
      keyNotes: [
        'NIVEX hiện không xử lý tiền thật hoặc kết nối ngân hàng thật.',
        'NIVEX chưa phải tổ chức cung cấp dịch vụ tài sản mã hóa được cấp phép.',
        'Tỷ giá, phí và số VND trong luồng này đều là dữ liệu demo.',
      ],
      practicalExample: 'Minh Anh xem 500 USDC trong số dư demo, tạo báo giá tham khảo và theo dõi payout VND mô phỏng.',
    ),

    // 2. Web3 là gì?
    EducationTopic(
      id: 'web3_intro',
      title: 'Web3 là gì?',
      shortDescription: 'Web3 là cách sử dụng các ứng dụng kết nối với mạng blockchain, nơi một số dữ liệu giao dịch có thể được kiểm tra công khai.',
      definition: 'Trong Web3, một số giao dịch được ghi nhận trên blockchain thay vì chỉ lưu trong một hệ thống riêng. Điều này có thể giúp kiểm tra giao dịch, nhưng không có nghĩa mọi giao dịch đều không thể hoàn tác hoặc không có rủi ro.',
      steps: [
        EducationStepItem(label: 'Ứng dụng', icon: Icons.apps_rounded),
        EducationStepItem(
          label: 'Ví kết nối',
          icon: Icons.account_balance_wallet_outlined,
        ),
        EducationStepItem(label: 'Blockchain', isBlockchain: true),
      ],
      howItWorks: [
        'Ứng dụng có thể gửi yêu cầu kết nối đến một ví tương thích.',
        'Người dùng kiểm tra nội dung trước khi xác nhận yêu cầu.',
        'Một số dữ liệu giao dịch có thể được kiểm tra trên blockchain.',
      ],
      keyNotes: [
        'Kết nối ví không đồng nghĩa với việc mọi giao dịch đều an toàn.',
        'Cần kiểm tra mạng, địa chỉ và nội dung trước khi xác nhận.',
        'Không chia sẻ private key hoặc seed phrase với ứng dụng hay người khác.',
      ],
      practicalExample: 'NIVEX dùng dữ liệu mô phỏng hoặc Solana Devnet để minh họa cách một giao dịch có thể được theo dõi.',
    ),

    // 3. Blockchain là gì?
    EducationTopic(
      id: 'blockchain_basics',
      title: 'Blockchain là gì?',
      shortDescription: 'Blockchain là một mạng lưới ghi nhận và xác nhận dữ liệu giao dịch giữa nhiều máy tính.',
      definition: 'Một giao dịch blockchain thường có người gửi, người nhận, tài sản hoặc dữ liệu giao dịch, phí mạng, trạng thái xác nhận và mã giao dịch. Trong NIVEX, các ví dụ blockchain dùng Solana Devnet hoặc dữ liệu mô phỏng.',
      steps: [
        EducationStepItem(
          label: 'Giao dịch',
          icon: Icons.receipt_long_outlined,
        ),
        EducationStepItem(label: 'Nhiều Node', icon: Icons.dns_outlined),
        EducationStepItem(label: 'Sổ cái', icon: Icons.menu_book_outlined),
      ],
      howItWorks: [
        'Một yêu cầu giao dịch được gửi đến mạng lưới.',
        'Các máy tính trong mạng kiểm tra dữ liệu theo quy tắc chung.',
        'Trạng thái và mã giao dịch có thể được dùng để đối chiếu.',
      ],
      keyNotes: [
        'Không phải mọi dữ liệu đều được hiển thị công khai.',
        'Transaction signature giúp tra cứu một giao dịch cụ thể.',
        'Người dùng vẫn cần kiểm tra đúng mạng, địa chỉ và trạng thái.',
      ],
      practicalExample: 'Một transaction signature Devnet có thể được dùng để kiểm tra trạng thái giao dịch thử nghiệm trên Solana Explorer.',
    ),

    // 4. Solana Devnet là gì?
    EducationTopic(
      id: 'solana_devnet',
      title: 'Solana Devnet là gì?',
      shortDescription: 'Solana Devnet là mạng thử nghiệm để phát triển và kiểm tra ứng dụng.',
      definition: 'Devnet không phải mạng dùng cho tiền thật. Token và SOL trên Devnet chỉ dùng để thử nghiệm. Giao dịch Devnet giúp nhóm kiểm tra luồng kỹ thuật mà không sử dụng tài sản thật. NIVEX hiện không dùng Solana Mainnet.',
      steps: [
        EducationStepItem(
          label: 'Solana',
          icon: Icons.bolt_rounded,
          isSolana: true,
        ),
        EducationStepItem(label: 'Phân nhánh', icon: Icons.call_split_rounded),
        EducationStepItem(label: 'Devnet Test', icon: Icons.science_outlined),
      ],
      howItWorks: [
        'Devnet hoạt động tách biệt với Solana Mainnet.',
        'Ứng dụng dùng token thử nghiệm để kiểm tra luồng kỹ thuật.',
        'Dữ liệu Devnet có thể được đặt lại trong quá trình vận hành.',
      ],
      keyNotes: [
        'Token trên Devnet hoàn toàn không có giá trị tiền tệ thực tế.',
        'Dữ liệu trạng thái mạng Devnet có thể được đặt lại định kỳ.',
        'Tuyệt đối không chuyển token thật từ sàn giao dịch vào mạng Devnet.',
      ],
      practicalExample: 'Số dư 500 USDC trong NIVEX là dữ liệu demo hoặc token thử nghiệm, không phải tài sản thật.',
    ),

    // 5. Sử dụng an toàn
    EducationTopic(
      id: 'safety_guide',
      title: 'Sử dụng an toàn',
      shortDescription: 'Kiểm tra mạng, địa chỉ ví và thông tin giao dịch trước khi xác nhận.',
      definition: 'Không chia sẻ private key, seed phrase, mật khẩu hoặc mã xác thực. Nếu giao dịch có dấu hiệu bất thường, hãy dừng lại và kiểm tra thông tin.',
      steps: [
        EducationStepItem(
          label: 'Đúng mạng',
          icon: Icons.wifi_protected_setup_rounded,
        ),
        EducationStepItem(
          label: 'Soát địa chỉ',
          icon: Icons.rule_folder_outlined,
        ),
        EducationStepItem(label: 'Bảo vệ khóa', icon: Icons.security_rounded),
      ],
      howItWorks: [
        'Kiểm tra đúng mạng Solana và địa chỉ ví.',
        'Không gửi thông tin bảo mật cho bất kỳ ai.',
        'Nếu giao dịch có vấn đề, hãy dừng lại và kiểm tra thông tin.',
      ],
      keyNotes: [
        'Không tin lời hứa lợi nhuận hoặc chuyển tiền chắc chắn.',
        'Chuyển token nhầm mạng hoặc địa chỉ có thể gây mất tài sản.',
        'NIVEX demo không yêu cầu private key hoặc seed phrase.',
      ],
      practicalExample: 'Địa chỉ ví Solana thử nghiệm của bạn có dạng 7xKXtg...sgAsU; hãy luôn đối chiếu địa chỉ trước khi xác nhận giao dịch mô phỏng.',
    ),

    // 6. Tình huống minh họa
    EducationTopic(
      id: 'scenario_minh_anh',
      title: 'Tình huống minh họa',
      shortDescription: 'Một ví dụ giả lập về cách khoản thanh toán USDC có thể được theo dõi từ lúc gửi đến khi hiển thị số dư.',
      definition: 'Tình huống này minh họa một quy trình giả lập. Giao dịch dùng dữ liệu mô phỏng hoặc Solana Devnet và payout VND chỉ là mô phỏng.',
      isScenario: true,
      steps: [
        EducationStepItem(
          label: 'Bên gửi',
          icon: Icons.business_center_outlined,
        ),
        EducationStepItem(
          label: 'Solana Devnet',
          icon: Icons.attach_money_rounded,
        ),
        EducationStepItem(label: 'Ví NIVEX', icon: Icons.person_rounded),
        EducationStepItem(
          label: 'VND demo',
          icon: Icons.account_balance_outlined,
        ),
      ],
      howItWorks: [
        'Bên gửi tạo khoản thanh toán 100 USDC.',
        'Giao dịch được mô phỏng hoặc kiểm tra trên Solana Devnet.',
        'NIVEX cập nhật số dư demo và hiển thị báo giá mô phỏng.',
      ],
      scenarioSteps: [
        'Bên gửi tạo khoản thanh toán 100 USDC',
        'Giao dịch được mô phỏng hoặc kiểm tra trên Solana Devnet',
        'NIVEX cập nhật số dư demo của freelancer',
        'Freelancer xem báo giá USDC/VND mô phỏng',
        'Freelancer chọn tài khoản nhận VND demo',
        'Payout VND được đánh dấu hoàn tất trong môi trường mô phỏng',
      ],
      disclaimer: 'Đây chỉ là ví dụ minh họa. Không có USDC thật hoặc VND thật được chuyển.',
      keyNotes: [
        'Số dư của freelancer được cập nhật trong dữ liệu demo.',
        'Tỷ giá, phí và tài khoản nhận đều là dữ liệu mô phỏng.',
        'Trạng thái hoàn tất không có nghĩa tiền thật đã được chuyển.',
      ],
      practicalExample: 'Bên gửi tạo khoản thanh toán 100 USDC; Minh Anh thấy số dư demo và xem số VND dự kiến nhận trong bản mô phỏng.',
    ),
  ];

  @override
  State<NivexEducationSection> createState() => _NivexEducationSectionState();
}

class _NivexEducationSectionState extends State<NivexEducationSection>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final PageController _pageController;
  late final AnimationController _animController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage;
    _pageController = PageController(
      viewportFraction: 0.94,
      initialPage: widget.initialPage,
    );
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    );

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.initialOpenDetail) {
          _openDetail(
            context,
            NivexEducationSection.topics[widget.initialPage],
          );
        }
        final disableAnim =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        if (!disableAnim) {
          _animController.forward(from: 0.0);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final disableAnim =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!disableAnim &&
          !_animController.isAnimating &&
          _animController.value < 1.0) {
        _animController.forward();
      }
    } else {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
      final disableAnim =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!disableAnim) {
        _animController.forward(from: 0.0);
      }
    }
  }

  Future<void> _openDetail(BuildContext context, EducationTopic topic) async {
    _animController.stop();
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.88,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: _EducationDetailSheet(topic: topic),
        ),
      ),
    );
    if (mounted && !disableAnim && _animController.value < 1.0) {
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final topics = NivexEducationSection.topics;
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Section Header: Title & Indicator (1/6)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Hiểu nhanh cùng NIVEX',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                '${_currentIndex + 1}/${topics.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),

        // 2. Story Card Carousel (Manual Swipe - 6 Cards)
        SizedBox(
          height: 232,
          child: PageView.builder(
            controller: _pageController,
            itemCount: topics.length,
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final topic = topics[index];
              final isActive = index == _currentIndex;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 6,
                  right: index == topics.length - 1 ? 20 : 6,
                ),
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final progress = disableAnim
                        ? 1.0
                        : (isActive ? _animController.value : 1.0);
                    return _StoryCard(
                      topic: topic,
                      progress: progress,
                      onTap: () => _openDetail(context, topic),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // 3. Dot Indicators (6 dots)
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(topics.length, (i) {
              final isActive = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? theme.primary : theme.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),

        // 4. Contextual demo notice for Home
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: DemoNotice(),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.topic,
    required this.progress,
    required this.onTap,
  });

  final EducationTopic topic;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;

    return Material(
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Animated Illustration Band (~46.5% height: 108px)
            RepaintBoundary(
              child: Container(
                height: 108,
                width: double.infinity,
                color: theme.surfaceSubtle,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _AnimatedIllustrationBand(
                  topic: topic,
                  progress: progress,
                  isLarge: false,
                ),
              ),
            ),

            // Bottom Content Area (Title + Short Description + Tìm hiểu thêm)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        topic.shortDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tìm hiểu thêm',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: theme.primary,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: theme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedIllustrationBand extends StatelessWidget {
  const _AnimatedIllustrationBand({
    required this.topic,
    required this.progress,
    required this.isLarge,
  });

  final EducationTopic topic;
  final double progress;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final effectiveProgress = disableAnim ? 1.0 : progress;
    final timeline = EducationAnimationTimeline(effectiveProgress);
    final steps = topic.steps;

    return Semantics(
      label: 'Tiến trình minh họa ${topic.title}',
      value: '${(progress * 100).round()} phần trăm',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDense = steps.length > 3;
          final requestedConnectorWidth = isDense
              ? (isLarge ? 30.0 : 24.0)
              : (isLarge ? 46.0 : 38.0);
          final minimumNodeWidth = isDense
              ? (isLarge ? 40.0 : 38.0)
              : (isLarge ? 50.0 : 46.0);
          final connectorCount = steps.length - 1;
          final maximumConnectorWidth = connectorCount == 0
              ? 0.0
              : (constraints.maxWidth - minimumNodeWidth * steps.length) /
                    connectorCount;
          final connectorWidth = connectorCount == 0
              ? 0.0
              : requestedConnectorWidth
                    .clamp(18.0, maximumConnectorWidth)
                    .toDouble();
          final nodeWidth =
              (constraints.maxWidth - connectorWidth * connectorCount) /
              steps.length;
          final targetNodeSize = isDense
              ? (isLarge ? 54.0 : 46.0)
              : (isLarge ? 58.0 : 48.0);
          final nodeVisualSize = math.min(targetNodeSize, nodeWidth);
          final nodeIconSize = nodeVisualSize * (isDense ? 0.56 : 0.55);
          final connectorHeight = isLarge ? 32.0 : 26.0;
          final connectorTop = (nodeVisualSize - connectorHeight) / 2;
          final labelHeight = isLarge ? 30.0 : 24.0;
          final contentHeight = nodeVisualSize + 4 + labelHeight;

          return Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: contentHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    SizedBox(
                      width: nodeWidth,
                      child: _AnimatedNodeWidget(
                        icon: steps[i].icon,
                        label: steps[i].label,
                        isSolana: steps[i].isSolana,
                        isBlockchain: steps[i].isBlockchain,
                        blockchainProgress: steps[i].isBlockchain
                            ? (disableAnim
                                  ? 1.0
                                  : (steps.length == 3 && i == 2
                                        ? ((progress - 0.65) / 0.30).clamp(
                                            0.0,
                                            1.0,
                                          )
                                        : progress))
                            : 1.0,
                        opacity: i == 0
                            ? timeline.node1Opacity
                            : (i == 1
                                  ? (steps.length == 3
                                        ? timeline.node2Opacity
                                        : timeline.line1Progress)
                                  : (i == 2
                                        ? (steps.length == 3
                                              ? timeline.node3Opacity
                                              : timeline.node2Opacity)
                                        : timeline.node3Opacity)),
                        scale: i == 0
                            ? timeline.node1Scale
                            : (i == steps.length - 1
                                  ? timeline.node3Scale
                                  : timeline.node2Scale),
                        completionOpacity: i == steps.length - 1
                            ? timeline.completionOpacity
                            : 0.0,
                        completionScale: i == steps.length - 1
                            ? timeline.completionScale
                            : 1.0,
                        theme: theme,
                        isLarge: isLarge,
                        isDense: isDense,
                        nodeSize: nodeVisualSize,
                        iconSize: nodeIconSize,
                      ),
                    ),
                    if (i < steps.length - 1)
                      Padding(
                        padding: EdgeInsets.only(top: connectorTop),
                        child: SizedBox(
                          key: ValueKey(
                            'education-connector-${steps.length}-$i-${isLarge ? 'large' : 'compact'}',
                          ),
                          width: connectorWidth,
                          height: connectorHeight,
                          child: CustomPaint(
                            painter: EducationConnectorPainter(
                              progress: i == 0
                                  ? timeline.line1Progress
                                  : (i == 1 && steps.length > 3
                                        ? timeline.node2Opacity
                                        : timeline.line2Progress),
                              activeColor: theme.primary,
                              inactiveColor: theme.border,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EducationIllustrationPreview extends StatelessWidget {
  const EducationIllustrationPreview({
    required this.topic,
    required this.progress,
    required this.isLarge,
    super.key,
  });

  final EducationTopic topic;
  final double progress;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return _AnimatedIllustrationBand(
      topic: topic,
      progress: progress,
      isLarge: isLarge,
    );
  }
}

class _AnimatedNodeWidget extends StatelessWidget {
  const _AnimatedNodeWidget({
    required this.label,
    required this.isSolana,
    required this.opacity,
    required this.scale,
    required this.theme,
    required this.isLarge,
    required this.isDense,
    required this.nodeSize,
    required this.iconSize,
    this.icon,
    this.isBlockchain = false,
    this.blockchainProgress = 1.0,
    this.completionOpacity = 0.0,
    this.completionScale = 1.0,
  });

  final IconData? icon;
  final String label;
  final bool isSolana;
  final bool isBlockchain;
  final double blockchainProgress;
  final double opacity;
  final double scale;
  final NivexThemeExtension theme;
  final bool isLarge;
  final bool isDense;
  final double nodeSize;
  final double iconSize;
  final double completionOpacity;
  final double completionScale;

  @override
  Widget build(BuildContext context) {
    final fontSize = isDense
        ? (isLarge ? 11.5 : 10.0)
        : (isLarge ? 12.0 : 10.5);
    final labelHeight = isLarge ? 30.0 : 24.0;

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: ValueKey(
                    'education-node-$label-${isLarge ? 'large' : 'compact'}',
                  ),
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.border),
                  ),
                  alignment: Alignment.center,
                  child: isSolana
                      ? SolanaMark(width: iconSize)
                      : (isBlockchain
                            ? BlockchainNetworkIcon(
                                size: iconSize,
                                color: theme.primary,
                                progress: blockchainProgress,
                              )
                            : Icon(icon, color: theme.primary, size: iconSize)),
                ),
                if (completionOpacity > 0.01)
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: Opacity(
                      opacity: completionOpacity.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: completionScale,
                        child: Container(
                          width: isLarge ? 18 : 14,
                          height: isLarge ? 18 : 14,
                          decoration: BoxDecoration(
                            color: theme.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.surface,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.check_rounded,
                            size: isLarge ? 12 : 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: labelHeight,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                    height: 1.15,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EducationConnectorGeometry {
  const EducationConnectorGeometry({
    required this.lineStart,
    required this.lineEnd,
    required this.arrowTip,
    required this.arrowUpperWing,
    required this.arrowLowerWing,
  });

  final Offset lineStart;
  final Offset lineEnd;
  final Offset arrowTip;
  final Offset arrowUpperWing;
  final Offset arrowLowerWing;

  bool fitsInside(Size size) {
    return [lineStart, lineEnd, arrowTip, arrowUpperWing, arrowLowerWing].every(
      (point) =>
          point.dx >= 0 &&
          point.dx <= size.width &&
          point.dy >= 0 &&
          point.dy <= size.height,
    );
  }
}

class EducationConnectorPainter extends CustomPainter {
  EducationConnectorPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  EducationConnectorGeometry geometryFor(Size size, {double? atProgress}) {
    final y = size.height / 2;
    const horizontalInset = 3.0;
    final startX = horizontalInset.clamp(0.0, size.width / 2).toDouble();
    final endX = (size.width - horizontalInset)
        .clamp(startX, size.width)
        .toDouble();
    final available = endX - startX;
    final arrowLength = (available * 0.34).clamp(4.5, 7.5).toDouble();
    final arrowHalfHeight = (size.height * 0.22).clamp(3.5, 5.5).toDouble();
    final resolvedProgress = (atProgress ?? progress).clamp(0.0, 1.0);
    final arrowTipX =
        startX + arrowLength + (available - arrowLength) * resolvedProgress;
    final arrowBaseX = arrowTipX - arrowLength;

    return EducationConnectorGeometry(
      lineStart: Offset(startX, y),
      lineEnd: Offset(arrowBaseX, y),
      arrowTip: Offset(arrowTipX, y),
      arrowUpperWing: Offset(arrowBaseX, y - arrowHalfHeight),
      arrowLowerWing: Offset(arrowBaseX, y + arrowHalfHeight),
    );
  }

  EducationConnectorGeometry backgroundGeometryFor(Size size) {
    return geometryFor(size, atProgress: 1.0);
  }

  void _drawConnector(
    Canvas canvas,
    EducationConnectorGeometry geometry,
    Color color,
    double strokeWidth,
  ) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(geometry.lineStart, geometry.lineEnd, linePaint);

    final arrowPath = Path()
      ..moveTo(geometry.arrowTip.dx, geometry.arrowTip.dy)
      ..lineTo(geometry.arrowUpperWing.dx, geometry.arrowUpperWing.dy)
      ..lineTo(geometry.arrowLowerWing.dx, geometry.arrowLowerWing.dy)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawConnector(
      canvas,
      backgroundGeometryFor(size),
      inactiveColor.withValues(alpha: 0.55),
      2.5,
    );

    if (progress <= 0.001) return;
    _drawConnector(canvas, geometryFor(size), activeColor, 3.0);
  }

  @override
  bool shouldRepaint(EducationConnectorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

class BlockchainConnectorLine {
  const BlockchainConnectorLine({required this.start, required this.end});

  final Offset start;
  final Offset end;
}

class BlockchainNetworkGeometry {
  const BlockchainNetworkGeometry({
    required this.centerBlock,
    required this.outerBlocks,
    required this.connectorLines,
  });

  final RRect centerBlock;
  final List<RRect> outerBlocks;
  final List<BlockchainConnectorLine> connectorLines;

  int get totalBlocks => 1 + outerBlocks.length;

  bool fitsInside(Size size) {
    bool inBounds(Offset p) =>
        p.dx >= 0.0 && p.dx <= size.width && p.dy >= 0.0 && p.dy <= size.height;

    bool rectInBounds(Rect r) =>
        r.left >= 0.0 &&
        r.right <= size.width &&
        r.top >= 0.0 &&
        r.bottom <= size.height;

    if (!rectInBounds(centerBlock.outerRect)) return false;
    for (final block in outerBlocks) {
      if (!rectInBounds(block.outerRect)) return false;
    }
    for (final line in connectorLines) {
      if (!inBounds(line.start) || !inBounds(line.end)) return false;
    }
    return true;
  }
}

class BlockchainNetworkPainter extends CustomPainter {
  BlockchainNetworkPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  BlockchainNetworkGeometry geometryFor(Size size, {double? atProgress}) {
    final p = (atProgress ?? progress).clamp(0.0, 1.0);
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final c = Offset(w / 2, h / 2);

    final centerSize = (s * 0.34).clamp(5.0, 9.0);
    final outerSize = (s * 0.20).clamp(3.0, 5.5);
    final pad = (s * 0.04).clamp(0.5, 1.2);
    final centerRadius = (centerSize * 0.18).clamp(1.0, 2.0);
    final outerRadius = (outerSize * 0.18).clamp(0.8, 1.5);

    final centerRect = Rect.fromCenter(
      center: c,
      width: centerSize,
      height: centerSize,
    );
    final centerBlock = RRect.fromRectAndRadius(
      centerRect,
      Radius.circular(centerRadius),
    );

    final topRect = Rect.fromCenter(
      center: Offset(c.dx, pad + outerSize / 2),
      width: outerSize,
      height: outerSize,
    );
    final bottomRect = Rect.fromCenter(
      center: Offset(c.dx, h - pad - outerSize / 2),
      width: outerSize,
      height: outerSize,
    );
    final leftRect = Rect.fromCenter(
      center: Offset(pad + outerSize / 2, c.dy),
      width: outerSize,
      height: outerSize,
    );
    final rightRect = Rect.fromCenter(
      center: Offset(w - pad - outerSize / 2, c.dy),
      width: outerSize,
      height: outerSize,
    );

    final outerBlocks = [
      RRect.fromRectAndRadius(topRect, Radius.circular(outerRadius)),
      RRect.fromRectAndRadius(bottomRect, Radius.circular(outerRadius)),
      RRect.fromRectAndRadius(leftRect, Radius.circular(outerRadius)),
      RRect.fromRectAndRadius(rightRect, Radius.circular(outerRadius)),
    ];

    // Stage 2: lines draw outward from center to outer blocks (progress 0.25 to 0.70)
    final lineProgress = ((p - 0.25) / 0.45).clamp(0.0, 1.0);

    final topStart = Offset(c.dx, centerRect.top);
    final topTarget = Offset(c.dx, topRect.bottom);
    final bottomStart = Offset(c.dx, centerRect.bottom);
    final bottomTarget = Offset(c.dx, bottomRect.top);
    final leftStart = Offset(centerRect.left, c.dy);
    final leftTarget = Offset(leftRect.right, c.dy);
    final rightStart = Offset(centerRect.right, c.dy);
    final rightTarget = Offset(rightRect.left, c.dy);

    final lines = [
      BlockchainConnectorLine(
        start: topStart,
        end: Offset.lerp(topStart, topTarget, lineProgress)!,
      ),
      BlockchainConnectorLine(
        start: bottomStart,
        end: Offset.lerp(bottomStart, bottomTarget, lineProgress)!,
      ),
      BlockchainConnectorLine(
        start: leftStart,
        end: Offset.lerp(leftStart, leftTarget, lineProgress)!,
      ),
      BlockchainConnectorLine(
        start: rightStart,
        end: Offset.lerp(rightStart, rightTarget, lineProgress)!,
      ),
    ];

    return BlockchainNetworkGeometry(
      centerBlock: centerBlock,
      outerBlocks: outerBlocks,
      connectorLines: lines,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    final geom = geometryFor(size, atProgress: p);
    final s = math.min(size.width, size.height);
    final c = Offset(size.width / 2, size.height / 2);

    // Stage 1: Center block appears first (progress 0.0 to 0.35)
    final centerOpacity = (p / 0.35).clamp(0.0, 1.0);
    final centerScale = 0.70 + 0.30 * centerOpacity;

    // Stage 2: 4 connecting lines draw outward (progress 0.25 to 0.70)
    final lineProgress = ((p - 0.25) / 0.45).clamp(0.0, 1.0);

    // Stage 3: 4 outer blocks appear and complete (progress 0.60 to 1.0)
    final outerOpacity = ((p - 0.60) / 0.40).clamp(0.0, 1.0);
    final outerScale = 0.70 + 0.30 * outerOpacity;

    // 1. Draw connector lines
    if (lineProgress > 0.01) {
      final strokeWidth = (s * 0.07).clamp(1.25, 1.5);
      final linePaint = Paint()
        ..color = color.withValues(
          alpha: (color.a * lineProgress).clamp(0.0, 1.0),
        )
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square;

      for (final line in geom.connectorLines) {
        canvas.drawLine(line.start, line.end, linePaint);
      }
    }

    // 2. Draw center block
    if (centerOpacity > 0.01) {
      final centerPaint = Paint()
        ..color = color.withValues(
          alpha: (color.a * centerOpacity).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;

      if (centerScale < 0.999) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.scale(centerScale);
        canvas.translate(-c.dx, -c.dy);
        canvas.drawRRect(geom.centerBlock, centerPaint);
        canvas.restore();
      } else {
        canvas.drawRRect(geom.centerBlock, centerPaint);
      }
    }

    // 3. Draw outer blocks
    if (outerOpacity > 0.01) {
      final outerPaint = Paint()
        ..color = color.withValues(
          alpha: (color.a * outerOpacity).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;

      for (final block in geom.outerBlocks) {
        final bCenter = block.outerRect.center;
        if (outerScale < 0.999) {
          canvas.save();
          canvas.translate(bCenter.dx, bCenter.dy);
          canvas.scale(outerScale);
          canvas.translate(-bCenter.dx, -bCenter.dy);
          canvas.drawRRect(block, outerPaint);
          canvas.restore();
        } else {
          canvas.drawRRect(block, outerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BlockchainNetworkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class BlockchainNetworkIcon extends StatelessWidget {
  const BlockchainNetworkIcon({
    super.key,
    this.size = 18.0,
    this.color,
    this.progress = 1.0,
  });

  final double size;
  final Color? color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final iconColor = color ?? theme.primary;
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final effectiveProgress = disableAnim ? 1.0 : progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: BlockchainNetworkPainter(
          progress: effectiveProgress,
          color: iconColor,
        ),
      ),
    );
  }
}

class _EducationDetailSheet extends StatefulWidget {
  const _EducationDetailSheet({required this.topic});

  final EducationTopic topic;

  @override
  State<_EducationDetailSheet> createState() => _EducationDetailSheetState();
}

class _EducationDetailSheetState extends State<_EducationDetailSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheetAnimController;

  @override
  void initState() {
    super.initState();
    _sheetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final disableAnim =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        if (!disableAnim) {
          _sheetAnimController.forward(from: 0.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _sheetAnimController.dispose();
    super.dispose();
  }

  void _replay() {
    _sheetAnimController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final topic = widget.topic;
    final disableAnim = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Container(
      color: theme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header with Title & Replay Button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topic.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _replay,
                        tooltip: 'Phát lại',
                        icon: Icon(Icons.replay_rounded, color: theme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Large 2D Illustration Band (155px height)
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _sheetAnimController,
                      builder: (context, child) {
                        final progress = disableAnim
                            ? 1.0
                            : _sheetAnimController.value;
                        return Container(
                          height: 155,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.border),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: _AnimatedIllustrationBand(
                            topic: topic,
                            progress: progress,
                            isLarge: true,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Khái niệm
                  Text(
                    'KHÁI NIỆM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    topic.definition,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: theme.textSecondary,
                      height: 1.45,
                      letterSpacing: 0,
                    ),
                  ),
                  if (topic.id == 'nivex_flow' ||
                      topic.id == 'scenario_minh_anh') ...[
                    const SizedBox(height: 12),
                    const DemoNotice(),
                  ],
                  const SizedBox(height: 18),

                  // 4. Cách hoạt động (tối đa 3 bước) hoặc Quy trình tuần tự cho Scenario
                  if (topic.isScenario) ...[
                    Text(
                      'QUY TRÌNH TUẦN TỰ MINH HỌA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.border),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          for (
                            int i = 0;
                            i < topic.scenarioSteps.length;
                            i++
                          ) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: theme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    topic.scenarioSteps[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (i < topic.scenarioSteps.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 2,
                                    height: 10,
                                    color: theme.border,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    if (topic.disclaimer != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: theme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                topic.disclaimer!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    Text(
                      'CÁCH HOẠT ĐỘNG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (int i = 0; i < topic.howItWorks.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${i + 1}. ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                topic.howItWorks[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textPrimary,
                                  height: 1.35,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 16),

                  // 5. Section "Điều cần nhớ"
                  Text(
                    'ĐIỀU CẦN NHỚ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final note in topic.keyNotes) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: theme.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textPrimary,
                                height: 1.35,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 6. Section "Ví dụ trong NIVEX (Mô phỏng Devnet)"
                  Text(
                    'VÍ DỤ TRONG NIVEX (MÔ PHỎNG DEVNET)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.border),
                    ),
                    child: Text(
                      topic.practicalExample,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 7. Fixed "Đã hiểu" Button at Bottom
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(top: BorderSide(color: theme.divider)),
              ),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: theme.primary,
                  foregroundColor: theme.isDark
                      ? theme.background
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                ),
                child: const Text('Đã hiểu'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
