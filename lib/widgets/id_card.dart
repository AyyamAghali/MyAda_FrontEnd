import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class IdCard extends StatelessWidget {
  final String name;
  final String surname;
  final String status;
  final String idNumber;
  final String? photoUrl;

  const IdCard({
    super.key,
    required this.name,
    required this.surname,
    required this.status,
    required this.idNumber,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Card dimensions - modern aspect ratio (reduced outer spacing)
    final cardWidth = isMobile ? screenWidth - 16 : 360.0; // Reduced from 32 to 16 for tighter fit
    final cardHeight = isMobile ? (cardWidth * 0.58) : 210.0;
    
    // Modern spacing system
    final padding = isMobile ? 20.0 : 24.0;
    final photoSize = isMobile ? 100.0 : 110.0;
    
    // Softer ADA brand colors
    final primaryColor = AppColors.primary.withOpacity(0.15); // Soft blue tint
    final accentColor = AppColors.secondary.withOpacity(0.12); // Soft bordeaux tint

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 0, // Removed horizontal margin
        vertical: isMobile ? 4 : 8, // Minimal vertical margin
      ),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle gradient background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.white,
                        primaryColor,
                      ],
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: EdgeInsets.all(padding),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate the vertical offset to align photo with name block center
                    // Logo height + spacing + (name + surname + status) / 2
                    final logoHeight = isMobile ? 30.0 : 36.0;
                    final topSpacing = isMobile ? 16.0 : 20.0;
                    final nameHeight = (isMobile ? 20.0 : 22.0) * 1.2; // name line height
                    final surnameHeight = (isMobile ? 20.0 : 22.0) * 1.2; // surname line height
                    final nameGap = 2.0;
                    final statusHeight = 28.0; // approximate status badge height
                    final statusGap = 8.0;
                    
                    // Center of name block = logo height + top spacing + (name block total height / 2)
                    final nameBlockCenter = logoHeight + topSpacing + (nameHeight + nameGap + surnameHeight + statusGap + statusHeight) / 2;
                    final photoTopOffset = nameBlockCenter - (photoSize / 2);
                    
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo section - positioned to align with name block center
                        Padding(
                          padding: EdgeInsets.only(top: photoTopOffset.clamp(0.0, double.infinity)),
                          child: Container(
                            width: photoSize,
                            height: photoSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
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
                                      errorBuilder: (context, error, stackTrace) =>
                                          _buildPlaceholderPhoto(photoSize, photoSize),
                                    )
                                  : _buildPlaceholderPhoto(photoSize, photoSize),
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 16 : 20),
                        // Info section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top section: Logo and University name
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ADA Logo
                                  SizedBox(
                                    width: isMobile ? 50 : 60,
                                    height: isMobile ? 30 : 36,
                                    child: Image.asset(
                                      'assets/images/ada_logo.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'ADA',
                                              style: TextStyle(
                                                fontSize: isMobile ? 12 : 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // University name
                                  Flexible(
                                    child: Text(
                                      'ADA UNIVERSITY',
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isMobile ? 16 : 20),
                              // Name section - photo aligns with center of this block
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isMobile ? 16 : 20),
                              // ID number
                              Text(
                                'ID: P$idNumber',
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
                    );
                  },
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

