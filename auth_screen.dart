import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/data_init_service.dart';
import 'package:ascendant_reach/screens/dashboard_screen.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/theme.dart';
import 'package:ascendant_reach/services/translation_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isSignInMode = false;
  bool _isRegistering = false;
  bool _isPasswordResetMode = false;
  bool _isOtpMode = false;
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _resetEmailController = TextEditingController();
  final _resetPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // OTP verification
  String _generatedOtp = '';
  String _resetAccountInfo = '';
  
  // Animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    
    // Initialize services immediately
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      print('🚀 Initializing GOLDEN WINNERS CIRCLE...');
      
      // Initialize storage service first
      await StorageService.init();
      print('✅ Storage service initialized');
      
      // Check and initialize sample data if needed
      final members = StorageService.getMembers();
      if (members.isEmpty) {
        print('📋 Initializing sample data...');
        await DataInitService.initializeSampleData();
        print('✅ Sample data ready');
      } else {
        print('✅ Found ${members.length} existing members');
      }
      
      // Check for existing session
      final currentMember = StorageService.getCurrentMember();
      if (currentMember != null && mounted) {
        print('✅ Existing session found for: ${currentMember.name}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
      
      print('✅ GOLDEN WINNERS CIRCLE ready!');
    } catch (e) {
      print('❌ Initialization error: $e');
      // Continue with the app - don't block the UI
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _referralCodeController.dispose();
    _resetEmailController.dispose();
    _resetPhoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🚀 Signing in to GO-WIN International...');
      
      await StorageService.init();
      final members = StorageService.getMembers();
      
      // Find member by email or username
      final member = members.cast<Member?>().firstWhere(
        (m) => m?.email.toLowerCase() == _emailController.text.toLowerCase() ||
               m?.name.toLowerCase() == _emailController.text.toLowerCase(),
        orElse: () => null,
      );
      
      if (member != null) {
        // For demo purposes, accept basic password validation
        if (_passwordController.text == 'password123' || 
            _passwordController.text == member.id) {
          await StorageService.saveCurrentMember(member);
          _showSuccess('🎉 Welcome back, ${member.name}!');
          
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          _showError('Invalid password. Please try again.');
        }
      } else {
        _showError('Account not found. Please check your credentials or register.');
      }
    } catch (e) {
      print('❌ Sign in error: $e');
      _showError('Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _registerWithReferral() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty ||
        _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🚀 Registering new Golden Winner Member...');
      
      await StorageService.init();
      await DataInitService.initializeSampleData();
      
      final members = StorageService.getMembers();
      
      // Check if email already exists
      final existingMember = members.cast<Member?>().firstWhere(
        (m) => m?.email.toLowerCase() == _emailController.text.toLowerCase(),
        orElse: () => null,
      );
      
      if (existingMember != null) {
        _showError('Email already exists. Please use a different email or sign in.');
        return;
      }
      
      // Validate referral code if provided
      String referredBy = 'jayadmin'; // Default referrer
      if (_referralCodeController.text.isNotEmpty) {
        final referrer = members.cast<Member?>().firstWhere(
          (m) => m?.referralCode == _referralCodeController.text.toUpperCase(),
          orElse: () => null,
        );
        
        if (referrer != null) {
          referredBy = referrer.referralCode;
          print('✅ Valid referral code: ${_referralCodeController.text}');
        } else {
          _showError('Invalid referral code. Please check and try again.');
          return;
        }
      }
      
      // Create new member
      final newMember = Member(
        id: 'member_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        phoneNumber: _phoneController.text.trim(),
        referralCode: 'WIN${DateTime.now().millisecondsSinceEpoch % 100000}',
        referredBy: referredBy,
        joinDate: DateTime.now(),
        rank: MemberRank.starter,
        level: 1,
        boardPosition: -1,
        directReferrals: [],
        points: 0,
        walletBalance: 0.0,
        earningWallet: 0.0,
        isActive: true,
        profilePicture: 'https://picsum.photos/150/150?random=${DateTime.now().millisecondsSinceEpoch}',
      );
      
      // Add to referrer's direct referrals if not default
      if (referredBy != 'jayadmin') {
        final referrerIndex = members.indexWhere((m) => m.referralCode == referredBy);
        if (referrerIndex != -1) {
          members[referrerIndex].directReferrals.add(newMember.id);
        }
      }
      
      // Save new member
      members.add(newMember);
      StorageService.saveMembers(members);
      await StorageService.saveCurrentMember(newMember);
      
      _showSuccess('🎉 Welcome to GO-WIN International, ${newMember.name}!');
      
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      print('❌ Registration error: $e');
      _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _toggleMode() {
    setState(() {
      _isSignInMode = !_isSignInMode;
      _isRegistering = false;
      _isPasswordResetMode = false;
      _isOtpMode = false;
      // Clear all form fields when switching modes
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _phoneController.clear();
      _referralCodeController.clear();
      _resetEmailController.clear();
      _resetPhoneController.clear();
      _otpController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Language selector at the top
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButton<AppLanguage>(
                        value: TranslationService.currentLanguage,
                        onChanged: (AppLanguage? newLanguage) {
                          if (newLanguage != null) {
                            setState(() {
                              TranslationService.setLanguage(newLanguage);
                            });
                          }
                        },
                        items: TranslationService.getLanguageOptions(),
                        underline: Container(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                // Top spacing
                SizedBox(height: size.height * 0.08),
                
                // Animated Logo Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Logo with pulse animation
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    center: Alignment.center,
                                    colors: [
                                      Colors.amber.shade200,
                                      Colors.amber.shade400,
                                      Colors.amber.shade600,
                                      Colors.orange.shade500,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: 0.6),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/winners_circle_logo.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.amber.shade400,
                                                Colors.orange.shade600,
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.emoji_events_rounded,
                                            size: 100,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Title with gradient text effect
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.amber.shade700,
                              Colors.orange.shade600,
                              Colors.deepOrange.shade500,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'GO-WIN',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 40,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Subtitle
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.amber.shade600,
                              Colors.orange.shade500,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'INTERNATIONAL',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Colors.white,
                              letterSpacing: 3.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Circle subtitle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade300,
                                Colors.orange.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'GOLDEN WINNERS CIRCLE',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade100.withValues(alpha: 0.9),
                                Colors.orange.shade50.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.amber.shade400,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '🏆 Multi-Level Marketing Platform 🏆',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade800,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Authentication Container
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Mode Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isSignInMode = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isSignInMode ? Colors.amber.shade400 : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'SIGN IN',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: _isSignInMode ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isSignInMode = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isSignInMode ? Colors.green.shade400 : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'REGISTER',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: !_isSignInMode ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Form Fields
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isOtpMode
                              ? _buildOtpVerificationForm()
                              : _isPasswordResetMode 
                                  ? _buildPasswordResetForm() 
                                  : _isSignInMode 
                                      ? _buildSignInForm() 
                                      : _buildRegistrationForm(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isLoading ? [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ] : _isPasswordResetMode ? [
                                Colors.blue.shade400,
                                Colors.indigo.shade500,
                              ] : _isSignInMode ? [
                                Colors.amber.shade400,
                                Colors.orange.shade500,
                              ] : [
                                Colors.green.shade400,
                                Colors.teal.shade500,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (_isSignInMode ? Colors.amber.shade200 : Colors.green.shade200).withValues(alpha: 0.6),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : (_isOtpMode ? _verifyOtpAndResetPassword : _isPasswordResetMode ? _resetPassword : _isSignInMode ? _signIn : _registerWithReferral),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _isOtpMode
                                            ? 'Verifying OTP...'
                                            : _isPasswordResetMode 
                                                ? 'Sending OTP...' 
                                                : _isSignInMode 
                                                    ? 'Signing In...' 
                                                    : 'Registering...',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    _isOtpMode
                                        ? 'VERIFY OTP & RESET PASSWORD'
                                        : _isPasswordResetMode 
                                            ? 'SEND OTP CODE' 
                                            : _isSignInMode 
                                                ? 'SIGN IN TO PLATFORM' 
                                                : 'JOIN GOLDEN WINNERS CIRCLE',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (!_isLoading && !_isSignInMode && !_isPasswordResetMode) ...[   
                  const SizedBox(height: 20),
                  
                  // Referral Information
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Referral Registration',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Join through a Golden Winners Member referral code to unlock exclusive benefits and start earning immediately!',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (!_isLoading) ...[
                  const SizedBox(height: 30),
                        
                  // Feature highlights
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🏆 GO-WIN International Benefits',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.amber.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildFeatureItem('💰', 'Multi-Level Commissions', 'Earn from your network'),
                        _buildFeatureItem('🎯', '14-Member Board System', 'Structured earning opportunities'),
                        _buildFeatureItem('🌍', 'Global Network', 'Connect with winners worldwide'),
                        _buildFeatureItem('📱', 'Mobile Platform', 'Manage your business anywhere'),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _resetPassword() async {
    if (_resetEmailController.text.isEmpty && _resetPhoneController.text.isEmpty) {
      _showError('Please enter your email or phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔐 Initiating password reset for GO-WIN International...');
      
      await StorageService.init();
      final members = StorageService.getMembers();
      
      // Find member by email or phone
      Member? member;
      String contactInfo = '';
      
      if (_resetEmailController.text.isNotEmpty) {
        member = members.cast<Member?>().firstWhere(
          (m) => m?.email.toLowerCase() == _resetEmailController.text.toLowerCase(),
          orElse: () => null,
        );
        contactInfo = _resetEmailController.text;
      } else {
        member = members.cast<Member?>().firstWhere(
          (m) => m?.phoneNumber == _resetPhoneController.text,
          orElse: () => null,
        );
        contactInfo = _resetPhoneController.text;
      }
      
      if (member != null) {
        // Generate OTP code
        _generatedOtp = (100000 + math.Random().nextInt(900000)).toString();
        _resetAccountInfo = contactInfo;
        
        _showSuccess('📱 OTP sent to $contactInfo! Check your messages.');
        print('🔐 Generated OTP: $_generatedOtp'); // For demo purposes
        
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _isOtpMode = true;
          _isPasswordResetMode = false;
        });
      } else {
        _showError('Account not found. Please check your email or phone number.');
      }
    } catch (e) {
      print('❌ Password reset error: $e');
      _showError('Password reset failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtpAndResetPassword() async {
    if (_otpController.text.isEmpty) {
      _showError('Please enter the OTP code');
      return;
    }

    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showError('Please enter and confirm your new password');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (_otpController.text != _generatedOtp) {
      _showError('Invalid OTP code. Please check and try again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔐 Verifying OTP and resetting password...');
      
      // Find and update member password
      final members = StorageService.getMembers();
      final memberIndex = members.indexWhere((m) => 
        m.email.toLowerCase() == _resetAccountInfo.toLowerCase() ||
        m.phoneNumber == _resetAccountInfo
      );
      
      if (memberIndex != -1) {
        // In a real app, you would hash and store the password
        // For demo purposes, we'll just show success
        _showSuccess('🎉 Password reset successfully! You can now sign in with your new password.');
        
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          _isOtpMode = false;
          _isPasswordResetMode = false;
          _isSignInMode = true;
          _otpController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _resetEmailController.clear();
          _resetPhoneController.clear();
        });
      }
    } catch (e) {
      print('❌ OTP verification error: $e');
      _showError('OTP verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPasswordResetForm() {
    return Column(
      key: const ValueKey('reset'),
      children: [
        Text(
          'Reset Your Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.blue.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // Email Field
        TextField(
          controller: _resetEmailController,
          decoration: InputDecoration(
            labelText: 'Email Address (Optional)',
            hintText: 'Enter your registered email',
            prefixIcon: Icon(Icons.email_outlined, color: Colors.blue.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'OR',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Phone Field
        TextField(
          controller: _resetPhoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number (Optional)',
            hintText: 'Enter your registered phone',
            prefixIcon: Icon(Icons.phone_outlined, color: Colors.blue.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: 16),
        
        // Reset Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Enter either your email or phone number to reset your password',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Back to Sign In Button
        TextButton(
          onPressed: () {
            setState(() {
              _isPasswordResetMode = false;
              _isSignInMode = true;
              _isOtpMode = false;
              _resetEmailController.clear();
              _resetPhoneController.clear();
              _otpController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            });
          },
          child: Text(
            'Back to Sign In',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSignInForm() {
    return Column(
      key: const ValueKey('signin'),
      children: [
        Text(
          'Welcome Back, Golden Winner!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.amber.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // Email/Username Field
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email or Username',
            hintText: 'Enter your email or username',
            prefixIcon: Icon(Icons.person_outline, color: Colors.amber.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.amber.shade50,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: 16),
        
        // Password Field with visibility toggle
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.amber.shade600),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.amber.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.amber.shade50,
          ),
          obscureText: _obscurePassword,
        ),
        
        const SizedBox(height: 12),
        
        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _isPasswordResetMode = true;
                _isSignInMode = false;
                _isOtpMode = false;
                _emailController.clear();
                _passwordController.clear();
                _otpController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              });
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Sign In Help
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Enter your email and password to access your account',
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRegistrationForm() {
    return Column(
      key: const ValueKey('register'),
      children: [
        Text(
          'Join the Golden Winners Circle!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.green.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // Name Field
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
            prefixIcon: Icon(Icons.person_outline, color: Colors.green.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.green.shade50,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        
        const SizedBox(height: 16),
        
        // Email Field
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address *',
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined, color: Colors.green.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.green.shade50,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: 16),
        
        // Phone Field
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+1 234 567 8900',
            prefixIcon: Icon(Icons.phone_outlined, color: Colors.green.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.green.shade50,
          ),
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: 16),
        
        // Password Field with visibility toggle
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Create Password *',
            hintText: 'Choose a strong password',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.green.shade600),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.green.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.green.shade50,
          ),
          obscureText: _obscurePassword,
        ),
        
        const SizedBox(height: 16),
        
        // Referral Code Field
        TextField(
          controller: _referralCodeController,
          decoration: InputDecoration(
            labelText: 'Referral Code (Optional)',
            hintText: 'Enter referral code from your sponsor',
            prefixIcon: Icon(Icons.group_add_outlined, color: Colors.orange.shade600),
            suffixIcon: IconButton(
              icon: Icon(Icons.qr_code_scanner, color: Colors.orange.shade600),
              onPressed: () {
                // TODO: Implement QR code scanning
                _showInfo('QR Code scanning feature coming soon!');
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.orange.shade50,
          ),
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }
  
  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildOtpVerificationForm() {
    return Column(
      key: const ValueKey('otp'),
      children: [
        Text(
          'Verify OTP Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.indigo.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // OTP Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.sms, size: 16, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'OTP sent to $_resetAccountInfo',
                  style: TextStyle(
                    color: Colors.indigo.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // OTP Field
        TextField(
          controller: _otpController,
          decoration: InputDecoration(
            labelText: 'Enter OTP Code',
            hintText: '123456',
            prefixIcon: Icon(Icons.verified_user, color: Colors.indigo.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.indigo.shade50,
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
          maxLength: 6,
        ),
        
        const SizedBox(height: 16),
        
        // New Password Field
        TextField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter your new password',
            prefixIcon: Icon(Icons.lock_reset, color: Colors.indigo.shade600),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.indigo.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.indigo.shade50,
          ),
          obscureText: _obscureNewPassword,
        ),
        
        const SizedBox(height: 16),
        
        // Confirm Password Field
        TextField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            hintText: 'Re-enter your new password',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.indigo.shade600),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.indigo.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo.shade500, width: 2),
            ),
            filled: true,
            fillColor: Colors.indigo.shade50,
          ),
          obscureText: _obscureNewPassword,
        ),
        
        const SizedBox(height: 16),
        
        // Demo OTP Display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo OTP: $_generatedOtp',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Resend OTP Button
        TextButton(
          onPressed: () {
            _resetPassword(); // Resend OTP
          },
          child: Text(
            'Resend OTP Code',
            style: TextStyle(
              color: Colors.indigo.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}