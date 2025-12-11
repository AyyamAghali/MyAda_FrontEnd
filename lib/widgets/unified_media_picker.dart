import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

class UnifiedMediaPicker extends StatelessWidget {
  final VoidCallback? onPhotoSelected;
  final VoidCallback? onCameraSelected;
  final VoidCallback? onVideoSelected;
  final String? label;
  final IconData? icon;
  final bool isFullWidth;
  final double? height;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final bool showVideoOption;

  const UnifiedMediaPicker({
    super.key,
    this.onPhotoSelected,
    this.onCameraSelected,
    this.onVideoSelected,
    this.label,
    this.icon,
    this.isFullWidth = true,
    this.height,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.showVideoOption = false,
  });

  void _showMediaSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onCameraSelected?.call();
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Choose from Library',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPhotoSelected?.call();
                  },
                ),
                if (showVideoOption && onVideoSelected != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.videocam,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Record Video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onVideoSelected?.call();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.video_library,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Choose Video from Library',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onVideoSelected?.call();
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultIcon = icon ?? Icons.add_photo_alternate;
    final defaultLabel = label ?? 'Add Photo';
    final defaultHeight = height ?? 56.0;
    final defaultBgColor = backgroundColor ?? AppColors.white;
    final defaultIconColor = iconColor ?? AppColors.primary;
    final defaultTextColor = textColor ?? AppColors.primary;

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: defaultHeight,
        child: OutlinedButton.icon(
          onPressed: () => _showMediaSourceSheet(context),
          icon: Icon(defaultIcon, color: defaultIconColor),
          label: Text(
            defaultLabel,
            style: TextStyle(
              color: defaultTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: defaultBgColor,
            side: BorderSide(color: AppColors.gray300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () => _showMediaSourceSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: defaultHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: defaultBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                defaultIcon,
                color: defaultIconColor,
                size: defaultHeight > 100 ? 48 : 24,
              ),
              if (defaultHeight > 100) ...[
                const SizedBox(height: 8),
                Text(
                  defaultLabel,
                  style: TextStyle(
                    color: defaultTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG or JPG, Min: 200x200px',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  defaultLabel,
                  style: TextStyle(
                    color: defaultTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }
}

