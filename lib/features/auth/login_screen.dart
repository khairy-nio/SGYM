import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../shared/widgets/shared_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'mohamed@gymio.app');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;
  String? _socialLoading;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _socialLogin(String provider) async {
    setState(() => _socialLoading = provider);
    try {
      // Show realistic simulation
      await _showSocialAuthDialog(provider);
    } finally {
      if (mounted) setState(() => _socialLoading = null);
    }
  }

  Future<void> _showSocialAuthDialog(String provider) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SocialAuthDialog(provider: provider),
    );
    if (mounted) {
      switch (provider) {
        case 'google': await ref.read(authProvider.notifier).loginWithGoogle(); break;
        case 'facebook': await ref.read(authProvider.notifier).loginWithFacebook(); break;
        case 'apple': await ref.read(authProvider.notifier).loginWithApple(); break;
      }
      if (mounted) context.go('/home');
    }
  }

  Future<void> _biometricLogin() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BiometricSheet(),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await ref.read(authProvider.notifier).loginWithBiometric();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Header background
                  Container(
                    height: size.height * 0.28,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D0D2B), Color(0xFF1A1A50)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const GymioLogo(size: 44, light: true),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome back! 👋',
                            style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to your account',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white60),
                          ),
                          const SizedBox(height: 32),
                          // Form Card
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    label: 'Email',
                                    hint: 'your@email.com',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Email is required';
                                      if (!v.contains('@')) return 'Enter valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    label: 'Password',
                                    hint: '••••••••',
                                    controller: _passwordController,
                                    obscureText: true,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _login(),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Password is required';
                                      if (v.length < 6) return 'Min 6 characters';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () => context.push('/forgot-password'),
                                      child: Text(
                                        'Forgot Password?',
                                        style: AppTextStyles.labelMedium.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  AppButton(
                                    label: 'Sign In',
                                    onPressed: _login,
                                    isLoading: _isLoading,
                                  ),
                                  const SizedBox(height: 20),
                                  // Biometric
                                  Center(
                                    child: GestureDetector(
                                      onTap: _biometricLogin,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.face_outlined,
                                              color: AppColors.primary,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Use Face ID',
                                            style: AppTextStyles.labelMedium.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // OR divider
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Social buttons
                                  SocialButton(
                                    label: 'Continue with Google',
                                    icon: _socialIcon('G', AppColors.google),
                                    onPressed: () => _socialLogin('google'),
                                    isLoading: _socialLoading == 'google',
                                  ),
                                  const SizedBox(height: 12),
                                  SocialButton(
                                    label: 'Continue with Facebook',
                                    icon: _socialIcon('f', AppColors.facebook),
                                    onPressed: () => _socialLogin('facebook'),
                                    isLoading: _socialLoading == 'facebook',
                                  ),
                                  const SizedBox(height: 12),
                                  SocialButton(
                                    label: 'Continue with Apple',
                                    icon: const Icon(Icons.apple, size: 22, color: Colors.black),
                                    onPressed: () => _socialLogin('apple'),
                                    isLoading: _socialLoading == 'apple',
                                  ),
                                  const SizedBox(height: 28),
                                  // Create account
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => context.push('/signup'),
                                      child: RichText(
                                        text: TextSpan(
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          children: [
                                            const TextSpan(text: "Don't have an account? "),
                                            TextSpan(
                                              text: 'Create Account',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(String letter, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }
}

// ── SOCIAL AUTH DIALOG ─────────────────────────────────────────────────────

class _SocialAuthDialog extends StatefulWidget {
  final String provider;
  const _SocialAuthDialog({required this.provider});

  @override
  State<_SocialAuthDialog> createState() => _SocialAuthDialogState();
}

class _SocialAuthDialogState extends State<_SocialAuthDialog> {
  int _step = 0; // 0=loading, 1=success

  @override
  void initState() {
    super.initState();
    _runFlow();
  }

  Future<void> _runFlow() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _step = 1);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  String get _providerName {
    switch (widget.provider) {
      case 'google': return 'Google';
      case 'facebook': return 'Facebook';
      case 'apple': return 'Apple';
      default: return 'Social';
    }
  }

  Color get _providerColor {
    switch (widget.provider) {
      case 'google': return AppColors.google;
      case 'facebook': return AppColors.facebook;
      case 'apple': return Colors.black;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step == 0) ...[
              CircularProgressIndicator(color: _providerColor),
              const SizedBox(height: 20),
              Text(
                'Connecting to $_providerName...',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ] else ...[
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Authenticated!', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Signing you in...',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── BIOMETRIC SHEET ────────────────────────────────────────────────────────

class _BiometricSheet extends StatefulWidget {
  const _BiometricSheet();

  @override
  State<_BiometricSheet> createState() => _BiometricSheetState();
}

class _BiometricSheetState extends State<_BiometricSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;
  int _step = 0; // 0=scanning, 1=success

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _runFlow();
  }

  Future<void> _runFlow() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1500));
    HapticFeedback.heavyImpact();
    setState(() => _step = 1);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(32),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Transform.scale(
                scale: _step == 0 ? _pulse.value : 1.0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _step == 1
                        ? AppColors.secondaryLight
                        : AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _step == 1 ? Icons.check_rounded : Icons.face_outlined,
                    color: _step == 1 ? AppColors.success : AppColors.primary,
                    size: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _step == 0 ? 'Scan your Face ID' : 'Face ID Recognized!',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _step == 0
                  ? 'Look directly at your device to authenticate'
                  : 'Signing you in securely...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
