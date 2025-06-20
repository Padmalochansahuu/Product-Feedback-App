import 'package:feedback_app/core/constants/app_theme.dart';
import 'package:feedback_app/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final AuthService authService = Get.find();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxString _selectedRole = 'User'.obs;

  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        role: _selectedRole.value,
      );
      
      if (success) {
        // Clear form fields on successful registration
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        
        // Navigate to login screen - handled by AuthService
        Get.offAllNamed('/login');
      }
    }
  }

  Widget _buildRoleSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: AppTheme.largeRadius,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () => _selectedRole.value = 'User',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedRole.value == 'User'
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: AppTheme.mediumRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: _selectedRole.value == 'User'
                          ? Colors.white
                          : Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'User',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedRole.value == 'User'
                            ? Colors.white
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () => _selectedRole.value = 'Admin',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedRole.value == 'Admin'
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: AppTheme.mediumRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      color: _selectedRole.value == 'Admin'
                          ? Colors.white
                          : Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedRole.value == 'Admin'
                            ? Colors.white
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    ).animate().slideY(
          delay: 500.ms,
          duration: 400.ms,
          begin: 0.2,
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GradientBackground(
        gradient: AppTheme.primaryGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: size.height - MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  FadeTransition(
                    opacity: _fadeController,
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppTheme.xlRadius,
                            boxShadow: AppTheme.elevatedShadow,
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            size: 60,
                            color: AppTheme.primaryColor,
                          ),
                        ).animate().scale(
                              duration: 800.ms,
                              curve: Curves.elasticOut,
                            ),
                        const SizedBox(height: 32),
                        Text(
                          'FeedbackPro',
                          style:
                              Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ).animate().fadeIn(delay: 200.ms).slideY(
                              begin: 0.3,
                              duration: 600.ms,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 8),
                        Text(
                          'Create an account to share your feedback',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 400.ms).slideY(
                              begin: 0.3,
                              duration: 600.ms,
                              curve: Curves.easeOut,
                            ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create Account',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign up to start your feedback journey',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            
                            // Role Selection
                            Text(
                              'Select Role',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRoleSelector(),
                            const SizedBox(height: 24),
                            
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: AppTheme.smallRadius,
                                  ),
                                  child: const Icon(
                                    Icons.email_outlined,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your email';
                                }
                                if (!GetUtils.isEmail(value!.trim())) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ).animate().slideX(
                                  delay: 600.ms,
                                  duration: 400.ms,
                                  begin: -0.2,
                                ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: AppTheme.smallRadius,
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your password';
                                }
                                if (value!.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ).animate().slideX(
                                  delay: 700.ms,
                                  duration: 400.ms,
                                  begin: 0.2,
                                ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: AppTheme.smallRadius,
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please confirm your password';
                                }
                                if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ).animate().slideX(
                                  delay: 800.ms,
                                  duration: 400.ms,
                                  begin: -0.2,
                                ),
                            const SizedBox(height: 32),
                            Obx(() => AnimatedButton(
                                  onPressed: authService.isLoading.value
                                      ? null
                                      : _handleRegister,
                                  isLoading: authService.isLoading.value,
                                  child: Obx(() => Text(
                                        'Create ${_selectedRole.value} Account',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      )),
                                )).animate().slideY(
                                  delay: 900.ms,
                                  duration: 400.ms,
                                  begin: 0.3,
                                ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Already have an account? Sign In',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ).animate().fadeIn(delay: 1000.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}