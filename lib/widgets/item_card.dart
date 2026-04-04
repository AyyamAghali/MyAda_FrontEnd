import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/lost_item.dart';
import '../utils/constants.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray200.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.gray100,
                  child: const Icon(Icons.image, size: 20, color: AppColors.gray300),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.gray100,
                  child: const Icon(Icons.image, size: 20, color: AppColors.gray300),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.gray400),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.gray500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(
                        label: item.categoryString,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      _Tag(
                        label: item.isLostItem ? 'Lost' : 'Found',
                        color: item.isLostItem
                            ? AppColors.secondary
                            : Colors.green.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.gray300),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
