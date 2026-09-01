import 'package:flutter/material.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountDetail,
    required this.icon,
    required this.kind,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String amountDetail;
  final IconData icon;
  final TransactionKind kind;
}

enum TransactionKind { incoming, outgoing, exchange }
