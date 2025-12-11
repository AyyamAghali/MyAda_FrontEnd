import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/lost_item.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';

class ItemDetailView extends StatelessWidget {
  final LostItem item;

  const ItemDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: AppColors.backgroundLight,
          child: Column(
            children: [
              _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle(context),
                          const SizedBox(height: 16),
                          _buildDescription(context),
                          const SizedBox(height: 12),
                          _buildItemDetails(context),
                          const SizedBox(height: 12),
                          _buildTimeline(context),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: AppColors.gray700, size: 22),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to bookmarks (mock).')),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.gray700, size: 22),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share dialog would open here (mock).')),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 240, // Reduced from 320 (25% reduction)
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.gray200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.gray200,
                  child: const Icon(Icons.image, size: 64),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#LF-${item.id.padLeft(6, '0')}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;

    switch (item.status) {
      case ItemStatus.active:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case ItemStatus.pendingVerification:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case ItemStatus.resolved:
        bgColor = AppColors.gray100;
        textColor = AppColors.gray700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        item.statusString,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.categoryString.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: AppColors.gray500),
            const SizedBox(width: 4),
            Text(
              item.location,
              style: const TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
            const SizedBox(width: 12),
            Icon(Icons.calendar_today, size: 14, color: AppColors.gray500),
            const SizedBox(width: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(DateTime.parse(item.dateFound)),
              style: const TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildDescription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Details',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Category', item.categoryString),
          const Divider(height: 20),
          _buildDetailRow('Status', item.statusString),
          const Divider(height: 20),
          _buildDetailRow('Reference #', 'LF-${item.id.padLeft(6, '0')}'),
          const Divider(height: 20),
          _buildDetailRow('Date Posted', DateFormat('MMM dd, yyyy').format(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray900),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          _buildTimelineItem('Verified', 'Item verified by staff', true),
          _buildTimelineItem('Submitted', 'Item reported and submitted', false),
          _buildTimelineItem('Found', 'Item found at ${item.location}', false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String status, String description, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.gray200,
                  shape: BoxShape.circle,
                ),
                child: isActive
                    ? const Icon(Icons.check, color: AppColors.white, size: 14)
                    : Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.gray400,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              if (status != 'Found')
                Container(
                  width: 2,
                  height: 40,
                  color: AppColors.gray200,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.gray900 : AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Contact Lost & Found Office'),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Office Location: Main Building, Ground Floor, Room 005'),
                                SizedBox(height: 8),
                                Text('Phone: +994 12 437 32 35'),
                                SizedBox(height: 8),
                                Text('Working hours: Mon–Fri, 9:00–18:00'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Contact Office',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirm Claim'),
                            content: const Text(
                              'By confirming, you acknowledge that you are the rightful owner of this item and will be asked to verify ownership at the Lost & Found office.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Claim submitted to staff (mock).')),
                                  );
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'This is Mine',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Issue reported to staff (mock).')),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_problem, size: 16, color: AppColors.gray600),
                  const SizedBox(width: 6),
                  Text(
                    'Report Issue',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

