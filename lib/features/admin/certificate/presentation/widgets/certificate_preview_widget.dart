import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';

class CertificatePreviewWidget extends StatelessWidget {
  final String templateId;
  final String participantName;
  final String eventTitle;
  final String eventDate;
  final String certificateNumber;
  final String signedBy;

  const CertificatePreviewWidget({
    super.key,
    required this.templateId,
    required this.participantName,
    required this.eventTitle,
    required this.eventDate,
    required this.certificateNumber,
    this.signedBy = 'OSIS SMKN 20 Jakarta',
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.414, // A4 ratio
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Border
            _buildDecorativeBorder(),
            
            // Main Content
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Certificate Title
                  Text(
                    'CERTIFICATE',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  Text(
                    'OF PARTICIPATION',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 4,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // "This certificate is awarded to"
                  Text(
                    'This certificate is proudly presented to',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Participant Name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      participantName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Event Description
                  Text(
                    'for successfully participating in',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Event Title
                  Text(
                    eventTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Event Date
                  Text(
                    'held on $eventDate',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Footer with Signature and Certificate Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Certificate Number
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Certificate No.',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            certificateNumber,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      
                      // Signature
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 120,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.textTertiary,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '___________',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            signedBy,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'Authorized Signature',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textTertiary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeBorder() {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            // Corner decorations
            _buildCornerDecoration(Alignment.topLeft),
            _buildCornerDecoration(Alignment.topRight),
            _buildCornerDecoration(Alignment.bottomLeft),
            _buildCornerDecoration(Alignment.bottomRight),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerDecoration(Alignment alignment) {
    return Positioned(
      top: alignment.y < 0 ? 0 : null,
      bottom: alignment.y > 0 ? 0 : null,
      left: alignment.x < 0 ? 0 : null,
      right: alignment.x > 0 ? 0 : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(4) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(4) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(4) : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight ? const Radius.circular(4) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
