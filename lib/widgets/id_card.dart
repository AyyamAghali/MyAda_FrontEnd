import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';

class IdCard extends StatelessWidget {
  final String name;
  final String surname;
  final String status;
  final String className;
  final String dateOfIssue;
  final String validityDate;
  final String idNumber;
  final String? photoUrl;

  const IdCard({
    super.key,
    required this.name,
    required this.surname,
    required this.status,
    required this.className,
    required this.dateOfIssue,
    required this.validityDate,
    required this.idNumber,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);
    
    // Responsive sizing - more conservative for small screens
    final availableWidth = screenWidth - (isMobile ? 32 : 48); // Account for margins
    final cardPadding = isMobile ? 12.0 : 20.0;
    final photoWidth = isMobile ? (availableWidth * 0.20).clamp(60.0, 90.0) : 120.0;
    final photoHeight = isMobile ? photoWidth * 1.25 : 150.0;
    final padding = isMobile ? 10.0 : 20.0;
    final spacing = isMobile ? 8.0 : 20.0;
    final headerFontSize = isMobile ? 16.0 : 24.0;
    final labelFontSize = isMobile ? 9.0 : 12.0;
    final valueFontSize = isMobile ? 11.0 : 14.0;
    final dateFontSize = isMobile ? 7.5 : 9.0;
    final watermarkSize = isMobile ? 80.0 : 120.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary, width: 2),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Watermark
            Positioned(
              right: -10,
              top: -10,
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  'ADA',
                  style: TextStyle(
                    fontSize: watermarkSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo
                  Flexible(
                    flex: 0,
                    child: Container(
                      width: photoWidth,
                      height: photoHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray300, width: 2),
                        color: AppColors.gray100,
                      ),
                      child: photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderPhoto(context, isMobile);
                                },
                              ),
                            )
                          : _buildPlaceholderPhoto(context, isMobile),
                    ),
                  ),
                  SizedBox(width: spacing),
                  // Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ADA University Header
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'ADA',
                                style: TextStyle(
                                  fontSize: headerFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: isMobile ? 1 : 2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: isMobile ? 4 : 8),
                            Container(
                              width: isMobile ? 20 : 32,
                              height: isMobile ? 20 : 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  'ADA',
                                  style: TextStyle(
                                    fontSize: isMobile ? 5 : 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          'UNIVERSITY',
                          style: TextStyle(
                            fontSize: isMobile ? 8 : 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        _buildInfoRow('Name:', name, labelFontSize, valueFontSize),
                        SizedBox(height: isMobile ? 6 : 8),
                        _buildInfoRow('Surname:', surname, labelFontSize, valueFontSize),
                        SizedBox(height: isMobile ? 6 : 8),
                        _buildInfoRow('Status:', status, labelFontSize, valueFontSize),
                        SizedBox(height: isMobile ? 6 : 8),
                        _buildInfoRow('Class:', className, labelFontSize, valueFontSize),
                        SizedBox(height: isMobile ? 8 : 12),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Date of issue:',
                                    style: TextStyle(
                                      fontSize: dateFontSize,
                                      color: AppColors.gray500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    dateOfIssue,
                                    style: TextStyle(
                                      fontSize: dateFontSize,
                                      color: AppColors.gray700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: isMobile ? 6 : 12),
                            Flexible(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Validity date:',
                                    style: TextStyle(
                                      fontSize: dateFontSize,
                                      color: AppColors.gray500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    validityDate,
                                    style: TextStyle(
                                      fontSize: dateFontSize,
                                      color: AppColors.gray700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // NFC/WiFi Symbol and ID Number
            Positioned(
              bottom: isMobile ? 8 : 16,
              right: isMobile ? 8 : 20,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? 80 : 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 5 : 8),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.nfc,
                        size: isMobile ? 18 : 24,
                        color: AppColors.gray600,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      'ID: $idNumber',
                      style: TextStyle(
                        fontSize: isMobile ? 8 : 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray700,
                        letterSpacing: isMobile ? 0.5 : 1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.end,
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

  Widget _buildInfoRow(String label, String value, double labelSize, double valueSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 0,
          child: Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: labelSize * 0.7),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderPhoto(BuildContext context, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: isMobile ? 40 : 60,
          color: AppColors.gray400,
        ),
      ),
    );
  }
}

