import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class IdCard extends StatelessWidget {
  final String name;
  final String surname;
  final String status;
  final String idNumber;
  final String idLabel;
  final String? photoUrl;

  const IdCard({
    super.key,
    required this.name,
    required this.surname,
    required this.status,
    required this.idNumber,
    this.idLabel = 'ID',
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Card dimensions - modern aspect ratio (reduced outer spacing)
    final cardWidth = isMobile
        ? screenWidth - 16
        : 360.0; // Reduced from 32 to 16 for tighter fit
    final cardHeight = isMobile ? (cardWidth * 0.58) : 210.0;

    // Modern spacing system
    final padding = isMobile ? 20.0 : 24.0;
    final photoSize = isMobile ? 100.0 : 110.0;

    final primaryTint = AppColors.primary.withValues(alpha: 0.16);
    final secondaryWash = AppColors.secondary.withValues(alpha: 0.07);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 0,
        vertical: isMobile ? 4 : 8,
      ),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.14),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.white,
                        Color.lerp(AppColors.white, AppColors.primary, 0.05)!,
                        primaryTint,
                        secondaryWash,
                      ],
                      stops: const [0.0, 0.35, 0.72, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: isMobile ? 32 : 38,
                          width: photoSize,
                          child: Image.asset(
                            'assets/images/ada_logo.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'ADA',
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isMobile ? 10 : 12),
                        Container(
                          width: photoSize,
                          height: photoSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: photoUrl != null
                                ? Image.network(
                                    photoUrl!,
                                    width: photoSize,
                                    height: photoSize,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildPlaceholderPhoto(
                                                photoSize, photoSize),
                                  )
                                : _buildPlaceholderPhoto(
                                    photoSize, photoSize),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: isMobile ? 16 : 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADA UNIVERSITY',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 1.15,
                            ),
                          ),
                          SizedBox(height: isMobile ? 6 : 7),
                          Container(
                            width: isMobile ? 48 : 56,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.primary,
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 14 : 18),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            surname,
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.secondaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          Text(
                            '$idLabel: $idNumber',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gray100,
            AppColors.gray200,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: width * 0.4,
          color: AppColors.gray400,
        ),
      ),
    );
  }
}
