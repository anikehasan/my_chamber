import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/mock_chamber_data.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'doctor@mychamber.com');
  final _passwordController = TextEditingController(text: '123456');

  String _selectedRole = 'doctor';
  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _pulseController;
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutQuart,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    ref.read(userRoleProvider.notifier).state = _selectedRole;
    setState(() => _isLoading = false);
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Rich Medical Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF052E30),
                  Color(0xFF0A5C60),
                  Color(0xFF118A91),
                ],
              ),
            ),
          ),

          // 2. Animated Ambient Floating Orbs
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final dy = math.sin(_pulseController.value * math.pi) * 18;
              return Positioned.fill(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -80 + dy,
                      left: -60,
                      child: _AmbientCircle(
                        size: 280,
                        color: const Color(0xFF2CEAA3).withValues(alpha: 0.12),
                      ),
                    ),
                    Positioned(
                      bottom: -100 - dy,
                      right: -40,
                      child: _AmbientCircle(
                        size: 340,
                        color: const Color(0xFF64DFDF).withValues(alpha: 0.14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 3. Main Responsive Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1060),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: isWide
                          ? Row(
                        children: [
                          Expanded(child: _buildBrandShowcase()),
                          const SizedBox(width: 48),
                          SizedBox(width: 440, child: _buildLoginCard()),
                        ],
                      )
                          : Column(
                        children: [
                          _buildMobileHeader(),
                          const SizedBox(height: 24),
                          ConstrainedBox(
                            constraints:
                            const BoxConstraints(maxWidth: 440),
                            child: _buildLoginCard(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandShowcase() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPulsingLogo(size: 72),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text(
              'NEXT-GEN CLINICAL WORKSPACE',
              style: TextStyle(
                color: Color(0xFF80FFDB),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MyChamber\nDigital Medical SaaS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Manage patient records, instant digital prescriptions, and encrypted lab reports across your chamber—seamlessly synced from any device.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 15.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 32),
          const _FeatureBadgeRow(
            icon: Icons.verified_user_outlined,
            title: 'Multi-Tenant Chamber Isolation',
            subtitle: '100% private patient data per medical chamber',
          ),
          const SizedBox(height: 16),
          const _FeatureBadgeRow(
            icon: Icons.receipt_long_outlined,
            title: '30-Second Smart Prescriptions',
            subtitle: 'Structured clinical Rx with instant print preview',
          ),
          const SizedBox(height: 16),
          const _FeatureBadgeRow(
            icon: Icons.cloud_done_outlined,
            title: 'Doctor & Assistant Role Sync',
            subtitle: 'Real-time queue & duplicate-safe patient serials',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildPulsingLogo(size: 64),
        const SizedBox(height: 14),
        const Text(
          'MyChamber',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Smart Digital Chamber & Patient Records',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPulsingLogo({required double size}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.07);
        return Transform.scale(
          scale: scale,
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2CEAA3), Color(0xFF0D7377)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CEAA3).withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.monitor_heart_rounded,
              color: Colors.white,
              size: size * 0.54,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginCard() {
    final isDoctor = _selectedRole == 'doctor';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              isDoctor
                  ? 'Access your chamber dashboard & prescriptions'
                  : 'Manage patient queue, serials & report uploads',
              key: ValueKey(_selectedRole),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 22),

          // Custom Animated Sliding Role Pill Switcher
          Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  alignment:
                  isDoctor ? Alignment.centerLeft : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.royalIndigo, Color(0xFF14919B)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.royalIndigo.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _selectedRole = 'doctor'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_rounded,
                              size: 18,
                              color: isDoctor ? Colors.white : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Doctor',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color:
                                isDoctor ? Colors.white : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            setState(() => _selectedRole = 'assistant'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.support_agent_rounded,
                              size: 18,
                              color:
                              !isDoctor ? Colors.white : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Assistant',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: !isDoctor
                                    ? Colors.white
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Gradient Action Button
          Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A5C60), Color(0xFF14919B)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.royalIndigo.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter Chamber Workspace',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      size: 20, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'New Doctor? ',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
              ),
              GestureDetector(
                onTap: () => context.push('/onboarding'),
                child: const Text(
                  'Create Your Chamber',
                  style: TextStyle(
                    color: AppTheme.royalIndigo,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmbientCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _FeatureBadgeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureBadgeRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: const Color(0xFF80FFDB), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}