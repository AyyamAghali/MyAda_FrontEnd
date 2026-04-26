import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lost_item.dart';
import '../../services/lost_found_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/responsive_container.dart';

class ItemDetailView extends StatefulWidget {
  final LostItem item;

  const ItemDetailView({super.key, required this.item});

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  final _service = LostFoundService();
  bool _isClaiming = false;

  LostItem get item => widget.item;

  Future<void> _submitClaim() async {
    setState(() => _isClaiming = true);
    try {
      await _service.claimItem(item.id);
      if (!mounted) return;
      Navigator.of(context).pop(); // close confirm dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kLostFoundUseMockData
              ? 'Claim submitted (mock – not sent to server)'
              : 'Claim submitted. Staff will review your request.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } on LostFoundException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        child: ResponsiveContainer(
          backgroundColor: AppColors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(context),
                      _buildTitleSection(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLocationBlock(context),
                            _buildDivider(),
                            _buildSectionTitle('Description'),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.gray600,
                                height: 1.6,
                              ),
                            ),
                            _buildDivider(),
                            _buildSectionTitle('Item Details'),
                            const SizedBox(height: 12),
                            _buildDetailRow('Category', item.categoryString),
                            _buildDetailRow('Type', item.typeString),
                            _buildDetailRow('Status', item.statusString),
                            _buildDetailRow(
                                'Reference', 'LF-${item.id.padLeft(6, '0')}'),
                            _buildDetailRow(
                              'Date Listed',
                              DateFormat('MMM dd, yyyy').format(DateTime.now()),
                            ),
                            _buildDivider(),
                            _buildSectionTitle('Timeline'),
                            const SizedBox(height: 14),
                            _buildTimelineItem(
                                'Verified', 'Item verified by staff', true),
                            _buildTimelineItem('Submitted',
                                'Item reported and submitted', false),
                            _buildTimelineItem(
                              'Found',
                              'Item found at ${item.location}',
                              false,
                              isLast: true,
                            ),
                            const SizedBox(height: 12),
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

  // ── Image ──────────────────────────────────────────────────────────

  Widget _buildImageSection(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openImageViewer(context),
          child: Hero(
            tag: 'item-image-${item.id}',
            child: Container(
              width: double.infinity,
              height: 320 + topPadding,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.gray200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.gray200,
                  child: const Icon(Icons.image, size: 64, color: AppColors.gray400),
                ),
              ),
            ),
          ),
        ),
        // Gradient overlay for readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.30),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: topPadding + 8,
          left: 16,
          child: AppBackButton(onPressed: () => Navigator.pop(context)),
        ),
        // Zoom hint
        Positioned(
          top: topPadding + 8,
          right: 16,
          child: _CircleButton(
            icon: Icons.zoom_in,
            onTap: () => _openImageViewer(context),
          ),
        ),
        // Status + reference overlaid at bottom-left of image
        Positioned(
          left: 20,
          bottom: 16,
          child: Row(
            children: [
              _buildStatusChip(),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#LF-${item.id.padLeft(6, '0')}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openImageViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(
          imageUrl: item.imageUrl,
          heroTag: 'item-image-${item.id}',
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildStatusChip() {
    Color bgColor;
    switch (item.status) {
      case ItemStatus.active:
        bgColor = Colors.green.shade500;
        break;
      case ItemStatus.pendingVerification:
        bgColor = Colors.orange.shade400;
        break;
      case ItemStatus.resolved:
        bgColor = AppColors.gray500;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.statusString,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.categoryString.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Location ───────────────────────────────────────────────────────

  Widget _buildLocationBlock(BuildContext context) {
    final parsed = _parseLocation(item.location);
    return _ExpandableLocationBlock(parsed: parsed);
  }

  _ParsedLocation _parseLocation(String location) {
    final lower = location.toLowerCase();

    if (lower.startsWith('campus')) {
      final detail = location.contains(' - ')
          ? location.split(' - ').sublist(1).join(' - ').trim()
          : (location.length > 7 ? location.substring(7).trim() : '');
      return _ParsedLocation(
        isCampus: true,
        building: '',
        detail: detail,
        isRoom: false,
      );
    }

    if (location.contains(' - ')) {
      final parts = location.split(' - ');
      final building = parts.first.trim();
      final rest = parts.sublist(1).join(' - ').trim();
      final isRoom = rest.toLowerCase().contains('room') ||
          RegExp(r'^[A-Z]?\d{2,4}$').hasMatch(rest.trim());
      return _ParsedLocation(
        isCampus: false,
        building: building,
        detail: rest,
        isRoom: isRoom,
      );
    }

    return _ParsedLocation(
      isCampus: false,
      building: location,
      detail: '',
      isRoom: false,
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.gray900,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: AppColors.gray200, height: 1),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: AppColors.gray500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String status, String description, bool isActive,
      {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.primary : AppColors.gray200,
                      shape: BoxShape.circle,
                    ),
                    child: isActive
                        ? const Icon(Icons.check,
                            color: AppColors.white, size: 13)
                        : Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.gray400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.gray200,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.gray900
                            : AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────

  Widget _buildBottomActions(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border:
              Border(top: BorderSide(color: AppColors.gray200, width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isClaiming
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (dlgCtx) => AlertDialog(
                        title: const Text('Confirm Claim'),
                        content: const Text(
                          'By confirming, you acknowledge that you are the rightful owner of this item and will be asked to verify ownership at the Lost & Found office.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dlgCtx).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: _submitClaim,
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                  },
            icon: _isClaiming
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.front_hand_outlined, size: 18),
            label: Text(
              _isClaiming ? 'Submitting…' : 'This is Mine',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Private helper classes
// ══════════════════════════════════════════════════════════════════════

class _ParsedLocation {
  final bool isCampus;
  final String building;
  final String detail;
  final bool isRoom;

  const _ParsedLocation({
    required this.isCampus,
    required this.building,
    required this.detail,
    required this.isRoom,
  });
}

class _ExpandableLocationBlock extends StatefulWidget {
  final _ParsedLocation parsed;
  const _ExpandableLocationBlock({required this.parsed});

  @override
  State<_ExpandableLocationBlock> createState() =>
      _ExpandableLocationBlockState();
}

class _ExpandableLocationBlockState extends State<_ExpandableLocationBlock>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  bool get _hasLongText {
    final p = widget.parsed;
    if (p.isCampus) return p.detail.length > 35;
    if (!p.isRoom && p.detail.length > 35) return true;
    return false;
  }

  void _toggle() {
    if (_hasLongText) setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.parsed;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    p.isCampus
                        ? Icons.park_outlined
                        : Icons.business_outlined,
                    size: 17,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.isCampus ? 'Campus Location' : 'Building Location',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
                if (_hasLongText)
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.gray400,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Rows
            if (p.isCampus) ...[
              _buildRow(
                Icons.place_outlined,
                'Area',
                p.detail.isNotEmpty ? p.detail : 'Campus',
              ),
            ] else ...[
              _buildRow(Icons.apartment, 'Building', p.building),
              if (p.detail.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildRow(
                  p.isRoom
                      ? Icons.meeting_room_outlined
                      : Icons.place_outlined,
                  p.isRoom ? 'Room' : 'Area',
                  p.detail,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: AppColors.gray500),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            secondChild: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 18),
      ),
    );
  }
}

// ── Fullscreen zoomable image viewer ─────────────────────────────────

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 64, color: AppColors.gray400),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: _CircleButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pinch to zoom',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
