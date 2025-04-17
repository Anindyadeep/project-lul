import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/verification_service.dart';

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({super.key});

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    final isVerified = await VerificationService.isVerified();
    if (isVerified && mounted) {
      Navigator.pushReplacementNamed(context, '/recommendations');
    }
  }

  // Simulate backend verification (for testing)
  Future<void> _simulateVerification() async {
    await VerificationService.simulateVerification();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/recommendations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Verification in Progress',
          style: GoogleFonts.nunitoSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F3FF).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  size: 60.w,
                  color: const Color(0xFF4299E1),
                ),
              ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
              SizedBox(height: 32.h),
              Text(
                'Please wait while we verify your information',
                style: GoogleFonts.nunitoSans(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
              SizedBox(height: 24.h),
              Text(
                'We are currently reviewing your verification details and adding you to our recommendation queue.',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  color: const Color(0xFF4A5568),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'What to expect:',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildInfoRow(
                      context,
                      'Verification Time',
                      'Usually completed within 24 hours',
                      Icons.timer,
                    ),
                    SizedBox(height: 16.h),
                    _buildInfoRow(
                      context,
                      'Recommendations and matches',
                      '2-3 matches every 2-3 days',
                      Icons.people,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: _simulateVerification,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56.h),
                  backgroundColor: const Color(0xFF4299E1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Simulate Verification (For Testing)',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F3FF).withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20.w, color: const Color(0xFF4299E1)),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  color: const Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
