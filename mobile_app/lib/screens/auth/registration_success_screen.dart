import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/shadcn_theme.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ShadcnThemeConfig.primaryColor.withOpacity(0.05),
              ShadcnThemeConfig.backgroundColor,
              ShadcnThemeConfig.secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ShadcnThemeConfig.successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_rounded,
                    size: 80,
                    color: ShadcnThemeConfig.successColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Text
                Text(
                  'Registration Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ShadcnThemeConfig.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Your account has been created. Please check your email to verify your account before signing in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: ShadcnThemeConfig.textSecondaryColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // Button
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        ShadcnThemeConfig.primaryColor,
                        ShadcnThemeConfig.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ShadcnThemeConfig.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.go('/login'),
                      borderRadius: BorderRadius.circular(16),
                      child: const Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
