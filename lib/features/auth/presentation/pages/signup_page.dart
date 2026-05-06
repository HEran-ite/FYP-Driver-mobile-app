import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/utils/ethiopia_phone.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _verificationId;
  int? _resendToken;
  String? _verifiedPhone;
  String? _verifiedFirebaseIdToken;

  static bool _firebaseReady = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final normalized = normalizeEthiopiaPhone(_phoneController.text);
    final changed = normalized == null || normalized != _verifiedPhone;
    if (!changed) return;
    if (_otpVerified || _otpSent || _verificationId != null) {
      setState(() {
        _otpVerified = false;
        _otpSent = false;
        _verificationId = null;
        _verifiedFirebaseIdToken = null;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _ensureFirebase() async {
    if (_firebaseReady) return;
    await Firebase.initializeApp();
    _firebaseReady = true;
  }

  Future<void> _sendOtp() async {
    final phoneNorm = normalizeEthiopiaPhone(_phoneController.text);
    if (phoneNorm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid phone before requesting OTP.',
          ),
        ),
      );
      return;
    }

    setState(() => _sendingOtp = true);
    try {
      await _ensureFirebase();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNorm,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            setState(() {
              _otpVerified = true;
              _otpSent = true;
              _verifiedPhone = phoneNorm;
              _verifiedFirebaseIdToken = idToken;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Phone number verified automatically.')),
            );
          } catch (_) {}
        },
        verificationFailed: (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Failed to send OTP.')),
          );
        },
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _otpSent = true;
            _otpVerified = false;
            _verifiedPhone = null;
            _verifiedFirebaseIdToken = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent. Check your SMS.')),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!mounted) return;
          setState(() => _verificationId = verificationId);
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP setup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    final verificationId = _verificationId;
    final phoneNorm = normalizeEthiopiaPhone(_phoneController.text);
    if (verificationId == null || verificationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request OTP first.')),
      );
      return;
    }
    if (phoneNorm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number.')),
      );
      return;
    }
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP code.')),
      );
      return;
    }
    setState(() => _verifyingOtp = true);
    try {
      await _ensureFirebase();
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      setState(() {
        _otpVerified = true;
        _verifiedPhone = phoneNorm;
        _verifiedFirebaseIdToken = idToken;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified successfully.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Invalid OTP code.')),
      );
    } finally {
      if (mounted) setState(() => _verifyingOtp = false);
    }
  }

  void _submit() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    final phoneNorm = normalizeEthiopiaPhone(_phoneController.text);
    if (phoneNorm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid phone: 09…, 251…, or +251… (9-digit mobile).',
          ),
        ),
      );
      return;
    }
    if (!_otpVerified || _verifiedPhone != phoneNorm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verify your phone with OTP before signup.')),
      );
      return;
    }
    final firebaseIdToken = _verifiedFirebaseIdToken?.trim();
    if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone verified, but Firebase token is missing. Verify OTP again.'),
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(SignupRequested(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: phoneNorm,
          password: password,
          firebaseIdToken: firebaseIdToken,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/driver-dashboard');
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.lg,
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                final busy = isLoading || _sendingOtp || _verifyingOtp;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _LogoSection(),
                    const SizedBox(height: Spacing.lg),
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Sign up to get started with CarCare',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: Spacing.xl),
                    Container(
                      padding: const EdgeInsets.all(Spacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('First Name', style: AppTextStyles.labelMedium),
                                    const SizedBox(height: Spacing.xs),
                                    TextField(
                                      controller: _firstNameController,
                                      enabled: !isLoading,
                                      decoration: const InputDecoration(hintText: 'John'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: Spacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Last Name', style: AppTextStyles.labelMedium),
                                    const SizedBox(height: Spacing.xs),
                                    TextField(
                                      controller: _lastNameController,
                                      enabled: !isLoading,
                                      decoration: const InputDecoration(hintText: 'Doe'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.lg),
                          Text('Email', style: AppTextStyles.labelMedium),
                          const SizedBox(height: Spacing.xs),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              hintText: 'you@example.com',
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          Text('Phone Number', style: AppTextStyles.labelMedium),
                          const SizedBox(height: Spacing.xs),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                                      enabled: !busy,
                            inputFormatters: const [EthiopiaPhoneInputFormatter()],
                            decoration: const InputDecoration(
                              hintText: '09…, 251…, or +251…',
                              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                            ),
                          ),
                                    const SizedBox(height: Spacing.sm),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: busy ? null : _sendOtp,
                                            icon: _sendingOtp
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  )
                                                : const Icon(Icons.sms_outlined),
                                            label: Text(_otpSent ? 'Resend OTP' : 'Send OTP'),
                                          ),
                                        ),
                                        const SizedBox(width: Spacing.sm),
                                        if (_otpVerified)
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: Colors.green,
                                          ),
                                      ],
                                    ),
                                    if (_otpSent) ...[
                                      const SizedBox(height: Spacing.md),
                                      Text('OTP Code', style: AppTextStyles.labelMedium),
                                      const SizedBox(height: Spacing.xs),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _otpController,
                                              keyboardType: TextInputType.number,
                                              enabled: !busy && !_otpVerified,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter 6-digit code',
                                                prefixIcon: Icon(
                                                  Icons.password_outlined,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: Spacing.sm),
                                          SizedBox(
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: busy || _otpVerified ? null : _verifyOtp,
                                              child: _verifyingOtp
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    )
                                                  : Text(_otpVerified ? 'Verified' : 'Verify'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                          const SizedBox(height: Spacing.lg),
                          Text('Password', style: AppTextStyles.labelMedium),
                          const SizedBox(height: Spacing.xs),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              hintText: 'At least 8 characters',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          Text('Confirm Password', style: AppTextStyles.labelMedium),
                          const SizedBox(height: Spacing.xs),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              hintText: 'Re-enter your password',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: busy ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.secondary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.secondary,
                                      ),
                                    )
                                  : const Text('Create Account'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  static const String _logoAsset = 'assets/images/app_logo.png';
  static const double _logoAspectRatio = 1024 / 682;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Dimensions.logoSize * 2,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.surfaceMuted),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
        child: AspectRatio(
          aspectRatio: _logoAspectRatio,
          child: Image.asset(
            _logoAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
