import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final maxWidth = Responsive.getMaxContentWidth(context);
    final containerPadding = padding ?? Responsive.getPadding(context);

    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: isMobile
          ? Container(
              padding: containerPadding,
              child: child,
            )
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  padding: containerPadding,
                  child: child,
                ),
              ),
            ),
    );
  }
}

