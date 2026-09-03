import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';

class DemoNotice extends StatelessWidget {
  const DemoNotice({
    this.text = 'Bản demo hackathon: giao dịch USDC sử dụng dữ liệu mô phỏng hoặc Solana Devnet. Payout VND là mô phỏng. Không có tiền thật được chuyển.',
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: theme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 12.5,
                height: 1.45,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
