import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import 'login_text_field.dart';

class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController nisController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;

  const LoginCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.nisController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 420 ? screenWidth * 0.88 : 420.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card - Compact and no overflow
        Container(
          width: cardWidth,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                // Logo dengan border
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: Text(
                              'E',
                              style: AppTextStyles.logo.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Heading
                Text(
                  'Selamat Datang',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Login untuk melanjutkan ke Eventty',
                  style: AppTextStyles.body2.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Nama Lengkap Field
                LoginTextField(
                  controller: nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama lengkap wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 9),

                // NIS Field
                LoginTextField(
                  controller: nisController,
                  label: 'NIS',
                  hint: 'Masukkan NIS',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIS wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 9),

                // Password Field
                LoginTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Masukkan password',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: true,
                  showPasswordToggle: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 2),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Lupa Password?',
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 11.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'LOGIN',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: onRegister,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Daftar',
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ),

        // Tape Effect (Top)
        Positioned(
          top: -10,
          left: cardWidth * 0.32,
          child: Container(
            width: cardWidth * 0.36,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFE8DCC8).withOpacity(0.85),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),

        // Decorative Doodles
        
        // Paper Plane - Top Left with dotted trail
        Positioned(
          top: 36,
          left: 24,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Dotted trail
              Positioned(
                right: 18,
                top: 8,
                child: CustomPaint(
                  size: const Size(30, 15),
                  painter: DottedLinePainter(),
                ),
              ),
              // Plane
              Transform.rotate(
                angle: -0.3,
                child: const Text(
                  '✈️',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ],
          ),
        ),

        // Stars - Top Right
        Positioned(
          top: 32,
          right: 20,
          child: const Text(
            '⭐',
            style: TextStyle(fontSize: 20),
          ),
        ),

        Positioned(
          top: 56,
          right: 36,
          child: Text(
            '✦',
            style: TextStyle(fontSize: 14, color: AppColors.primary),
          ),
        ),

        // Sparkle lines - Left
        Positioned(
          top: cardWidth * 0.32,
          left: 18,
          child: CustomPaint(
            size: const Size(20, 20),
            painter: SparklePainter(color: Colors.orange.shade300),
          ),
        ),

        // Leaf decoration - Left (subtle)
        Positioned(
          bottom: cardWidth * 0.46,
          left: 20,
          child: Opacity(
            opacity: 0.25,
            child: const Text(
              '🌿',
              style: TextStyle(fontSize: 48),
            ),
          ),
        ),

        // Heart outline - Bottom center-right
        Positioned(
          bottom: cardWidth * 0.22,
          right: cardWidth * 0.28,
          child: Icon(
            Icons.favorite_border_rounded,
            color: Colors.orange.shade300,
            size: 24,
          ),
        ),

        // Blue paint stroke - Right side
        Positioned(
          top: cardWidth * 0.54,
          right: 8,
          child: Transform.rotate(
            angle: 0.1,
            child: Container(
              width: 60,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        // Star outline - Bottom Right
        Positioned(
          bottom: 36,
          right: 16,
          child: Icon(
            Icons.star_border_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),

        // Smiley face - Bottom Right
        Positioned(
          bottom: 14,
          right: 20,
          child: const Text(
            '😊',
            style: TextStyle(fontSize: 18),
          ),
        ),

        // Blue curved line - Right side
        Positioned(
          bottom: cardWidth * 0.30,
          right: 12,
          child: CustomPaint(
            size: const Size(35, 35),
            painter: CurvedLinePainter(
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}

// Dotted line painter for plane trail
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double dashWidth = 3;
    double dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Sparkle painter
class SparklePainter extends CustomPainter {
  final Color color;

  SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vertical line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Diagonal lines
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.7),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Curved line painter
class CurvedLinePainter extends CustomPainter {
  final Color color;

  CurvedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
