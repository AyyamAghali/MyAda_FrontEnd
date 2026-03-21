import 'package:flutter/material.dart';

Color vacancyCategoryColor(String category) {
  switch (category) {
    case 'Technology':
      return const Color(0xFF3B82F6);
    case 'Marketing':
      return const Color(0xFFF97316);
    case 'Finance':
      return const Color(0xFF22C55E);
    case 'Media':
      return const Color(0xFFEC4899);
    case 'Engineering':
      return const Color(0xFF8B5CF6);
    case 'Arts':
      return const Color(0xFFEF4444);
    case 'Business':
      return const Color(0xFF22C55E);
    case 'Academic':
      return const Color(0xFF6366F1);
    default:
      return const Color(0xFF3B82F6);
  }
}

IconData vacancyCategoryIcon(String category) {
  switch (category) {
    case 'Marketing':
      return Icons.campaign_outlined;
    case 'Finance':
      return Icons.account_balance_wallet_outlined;
    case 'Media':
      return Icons.perm_media_outlined;
    case 'Engineering':
      return Icons.computer_outlined;
    case 'Arts':
      return Icons.palette_outlined;
    case 'Academic':
      return Icons.menu_book_outlined;
    default:
      return Icons.work_outline;
  }
}
