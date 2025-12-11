import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A versatile image view widget that supports different types of images (SVG, file, network, asset).
class CustomImageView extends StatelessWidget {
  final String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit fit;
  final String placeHolder;
  final Alignment alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final BorderRadius? radius;
  final BoxBorder? border;

  const CustomImageView({
    Key? key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/image_not_found.png',
    this.alignment = Alignment.center,
    this.onTap,
    this.radius,
    this.margin = EdgeInsets.zero,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: margin,
        child: _buildImageWidget(),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (imagePath == null || imagePath!.isEmpty) {
      return _sizedContainer(
        child: Image.asset(
          placeHolder,
          height: height,
          width: width,
          fit: fit,
          color: color,
        ),
      );
    }

    // Check image type
    if (imagePath!.endsWith('.svg')) {
      // SVG image
      return _sizedContainer(
        child: SvgPicture.asset(
          imagePath!,
          height: height,
          width: width,
          fit: fit,
          colorFilter:
              color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          alignment: alignment,
        ),
      );
    } else if (imagePath!.startsWith('http://') ||
        imagePath!.startsWith('https://')) {
      // Network image
      return _sizedContainer(
        child: CachedNetworkImage(
          imageUrl: imagePath!,
          height: height,
          width: width,
          fit: fit,
          color: color,
          alignment: alignment,
          placeholder: (context, url) => SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) => Image.asset(
            placeHolder,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (imagePath!.startsWith('file://')) {
      // File image
      return _sizedContainer(
        child: Image.file(
          File(imagePath!.replaceFirst('file://', '')),
          height: height,
          width: width,
          fit: fit,
          color: color,
          alignment: alignment,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            placeHolder,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else {
      // Asset image
      return _sizedContainer(
        child: Image.asset(
          imagePath!,
          height: height,
          width: width,
          fit: fit,
          color: color,
          alignment: alignment,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            placeHolder,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    }
  }

  Widget _sizedContainer({required Widget child}) {
    if (radius != null || border != null) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: border,
        ),
        child: ClipRRect(
          borderRadius: radius ?? BorderRadius.zero,
          child: child,
        ),
      );
    } else {
      return SizedBox(
        height: height,
        width: width,
        child: child,
      );
    }
  }
}
