import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/club.dart';
import '../utils/constants.dart';

/// Club directory card — matches MyAda_Front_Web `.clubs-card` (image, category pill, copy, navy CTA row).
class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onTap;

  const ClubCard({
    super.key,
    required this.club,
    required this.onTap,
  });

  String get _coverUrl => club.banner.isNotEmpty ? club.banner : club.logo;

  static List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.08),
          blurRadius: 45,
          offset: const Offset(0, 18),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray200),
          boxShadow: _cardShadow,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gridCell = constraints.maxHeight.isFinite;
            final body = _buildCardBody(gridCell);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: gridCell ? MainAxisSize.max : MainAxisSize.min,
              children: [
                _buildMedia(),
                if (gridCell)
                  Expanded(child: body)
                else
                  body,
              ],
            );
          },
        ),
      ),
    );
  }

  /// [gridCell]: true when laid out in a fixed-height grid — about text flexes to avoid vertical overflow.
  Widget _buildCardBody(bool gridCell) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: gridCell ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(
            club.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (gridCell)
            Expanded(
              child: Text(
                club.about,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Color(0xFF4B5563),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Text(
              club.about,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF4B5563),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: AppColors.gray400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${club.memberCount} members',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: ClubUiColors.ctaNavy,
                foregroundColor: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text(
                'View Details',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: AspectRatio(
        aspectRatio: 1 / 0.65,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _coverUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.gray200,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.gray200,
                child: const Icon(Icons.groups, size: 48, color: AppColors.gray400),
              ),
            ),
            Positioned(
              top: 14,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gray50.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  club.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Color(0xFF111827),
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
