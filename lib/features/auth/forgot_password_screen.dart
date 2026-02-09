import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // In a real Huawei OAuth implementation, password reset would typically involve:
        // 1. Sending user to Huawei's password reset page
        // 2. Using Huawei's password reset flow
        // For demo purposes, we'll simulate the email sending
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isEmailSent = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending reset email: \$e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(AppStrings.resetPassword),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                if (!_isEmailSent) ...[
                  // Reset password form
                  const Text(
                    AppStrings.passwordResetTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.passwordResetSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email input
                  AppInput(
                    label: AppStrings.emailLabel,
                    hint: 'Enter your email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Reset button
                  AppButton(
                    text: AppStrings.sendResetLink,
                    onPressed: _handleResetPassword,
                    width: double.infinity,
                    icon: Icons.send,
                  ),
                ] else ...[
                  // Success message
                  const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    AppStrings.emailSent,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.resetInstructions,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Check email button
                  AppButton(
                    text: AppStrings.checkEmail,
                    onPressed: () {
                      // In a real app, this might open the email app
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening email app...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    width: double.infinity,
                    isPrimary: false,
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 16),

                  // Resend button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEmailSent = false;
                        _emailController.clear();
                      });
                    },
                    child: const Text(
                      AppStrings.resendEmail,
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Back to login
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    AppStrings.backToLogin,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Support info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.greyLight),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Need Help?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'If you don\'t receive the email within a few minutes, please check your spam folder or contact support.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
