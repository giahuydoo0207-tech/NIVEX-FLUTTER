import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({required this.onCreateQuote, super.key});

  final VoidCallback onCreateQuote;

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Thị trường',
      subtitle: 'Tỷ giá USDC/VND tham khảo',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey('market-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              NivexCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'USDC / VND',
                      style: TextStyle(color: NivexColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '25.545',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 5, bottom: 3),
                                child: Text('VND'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '+0,12%',
                          style: TextStyle(
                            color: NivexColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: CustomPaint(painter: _RateChartPainter()),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('25.410', style: TextStyle(fontSize: 11)),
                        Text('7 ngày', style: TextStyle(fontSize: 11)),
                        Text('25.620', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: _RateStat(
                      label: 'Mở cửa',
                      value: '25.515',
                      icon: Icons.wb_sunny_outlined,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _RateStat(
                      label: 'Cao nhất',
                      value: '25.620',
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: _RateStat(
                      label: 'Thấp nhất',
                      value: '25.410',
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _RateStat(
                      label: 'Cập nhật',
                      value: '12:30',
                      icon: Icons.schedule_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const NivexCard(
                color: NivexColors.greenSoft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: NivexColors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tỷ giá trên màn hình là dữ liệu mô phỏng. Giá thực tế '
                        'được khóa trong 30 giây ở bước báo giá.',
                        style: TextStyle(height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onCreateQuote,
                icon: const Icon(Icons.request_quote_outlined),
                label: const Text('Tạo báo giá 250 USDC'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateStat extends StatelessWidget {
  const _RateStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return NivexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: NivexColors.blue, size: 20),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: NivexColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RateChartPainter extends CustomPainter {
  const _RateChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = NivexColors.border
      ..strokeWidth = 1;
    for (var index = 0; index <= 3; index++) {
      final y = size.height * index / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final points = [
      const Offset(0, .72),
      const Offset(.12, .61),
      const Offset(.24, .68),
      const Offset(.36, .44),
      const Offset(.48, .5),
      const Offset(.61, .31),
      const Offset(.73, .38),
      const Offset(.85, .2),
      const Offset(1, .27),
    ];
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final point = Offset(
        points[index].dx * size.width,
        points[index].dy * size.height,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = NivexColors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
