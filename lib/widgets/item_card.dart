import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/lost_item.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class ItemCard extends StatelessWidget {
  final LostItem item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final contentPadding = isMobile ? 12.0 : 16.0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.container),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.container),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 0,
                  child: _buildImage(context),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.gray400),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppColors.gray600),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.location,
                                style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.label, size: 14, color: AppColors.gray500),
                            const SizedBox(width: 4),
                            Text(
                              item.categoryString,
                              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: _buildStatusBadge(),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: AppColors.gray500),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _getDaysAgo(item.dateFound),
                                      style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(contentPadding, 0, contentPadding, contentPadding),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Text(
                  item.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final imageSize = isMobile ? 90.0 : 112.0;
    final margin = isMobile ? 12.0 : 16.0;
    
    return Container(
      width: imageSize,
      height: imageSize,
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppRadius.mediumLarge),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.mediumLarge),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.image),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AppRadius.smallMedium),
              ),
              child: Text(
                item.categoryIcon,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (item.status) {
      case ItemStatus.active:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        borderColor = Colors.green.shade200;
        break;
      case ItemStatus.pendingVerification:
        bgColor = Colors.yellow.shade50;
        textColor = Colors.yellow.shade700;
        borderColor = Colors.yellow.shade200;
        break;
      case ItemStatus.resolved:
        bgColor = AppColors.gray50;
        textColor = AppColors.gray600;
        borderColor = AppColors.gray200;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.smallMedium),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        item.statusString,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }

  String _getDaysAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      final difference = today.difference(date).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      return '$difference days ago';
    } catch (e) {
      return dateStr;
    }
  }
}

