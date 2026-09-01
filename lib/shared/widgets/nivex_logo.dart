import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';

class NivexLogo extends StatelessWidget {
  const NivexLogo({super.key, this.height = 28});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'NIVEX',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: NivexColors.blue,
              borderRadius: BorderRadius.circular(height * .3),
            ),
            child: Text(
              'N',
              style: TextStyle(
                color: NivexColors.white,
                fontSize: height * .58,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: height * .3),
          Text(
            'NIVEX',
            style: TextStyle(
              color: NivexColors.navy,
              fontSize: height * .62,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
