import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';

class DemoNotice extends StatelessWidget {
  const DemoNotice({
    this.text = 'Bản demo hackathon: giao dịch USDC sử dụng dữ liệu mô phỏng hoặc Solana Devnet. Payout VND là mô phỏng. Không có tiền thật được chuyển.',
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NivexColors.blueSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NivexColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: NivexColors.blue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: NivexColors.navy,
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
