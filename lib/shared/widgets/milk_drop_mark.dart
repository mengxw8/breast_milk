import 'package:flutter/material.dart';

class MilkDropMark extends StatelessWidget {
  const MilkDropMark({super.key, this.size = 72});

  static const assetName = 'assets/branding/dun_dun_dun_logo_1024.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: '吨吨吨，两大一小奶滴标志',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          assetName,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
