import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class ApprovalPendingScreen extends StatelessWidget {
  final String message;
  const ApprovalPendingScreen({super.key, this.message = "உங்கள் கணக்கு இன்னும் அங்கீகரிக்கப்படவில்லை."});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pending_actions_rounded, size: 80, color: Color(0xFFB58D3D)),
              const SizedBox(height: 30),
              const Text(
                'காத்திருக்கவும்...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
              const SizedBox(height: 15),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
              ),
              const SizedBox(height: 10),
              const Text(
                'நிர்வாகி (Admin) அனுமதி அளித்தவுடன் நீங்கள் ஆப்பைப் பயன்படுத்தலாம்.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF795548)),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: const Color(0xFFE65100), width: 1.2),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Reload or Check Status again (or just logout to retry)
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF5D1204),
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Refresh / Back', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
