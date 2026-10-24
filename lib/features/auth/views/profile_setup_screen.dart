import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

/// Password Confirmation & Driver Setup Screen (Step 2 of 2) for setting a password
/// to enable Email+Password login alongside Google/Facebook SSO or custom profile photo upload.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final TextEditingController _nicknameController;
  final _emergencyContactController = TextEditingController(text: '+880 1700-000000');
  bool _isPasswordVisible = false;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    final authCtrl = context.read<AuthController>();
    _nicknameController = TextEditingController(
      text: authCtrl.user.nickname.isNotEmpty ? authCtrl.user.nickname : 'Bengal Navigator',
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open image picker. Please check device permissions.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgBackgroundColor = isDark ? AppTheme.darkCanvas : const Color(0xFFF8FAFC);
    final cardBackgroundColor = isDark ? AppTheme.darkCard : Colors.white;
    final primaryTextColor = isDark ? Colors.white : AppTheme.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    final accountPhotoUrl = authCtrl.user.avatarUrl.isNotEmpty
        ? authCtrl.user.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';

    return Scaffold(
      backgroundColor: bgBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Top Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA3E6D2)),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(radius: 3, backgroundColor: AppTheme.primaryGreen),
                              SizedBox(width: 6),
                              Text(
                                'VERIFIED SOCIAL TOKEN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Symbols.history, size: 12, color: Color(0xFF475569)),
                              SizedBox(width: 4),
                              Text(
                                'STEP 2 OF 2',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: _pickedImageFile != null
                              ? FileImage(_pickedImageFile!) as ImageProvider
                              : NetworkImage(accountPhotoUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CONNECTED ACCOUNT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              Text(
                                authCtrl.user.email.isNotEmpty ? authCtrl.user.email : 'explorer@google.com',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Main Form Console: Set Password & Complete Profile
              Container(
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Confirmation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: primaryTextColor,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Set a password for your email. This allows you to log in directly using Email + Password in addition to Google/Facebook SSO.',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    Text(
                      'Create Password',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'At least 6 characters',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Symbols.visibility : Symbols.visibility_off,
                            size: 20,
                            color: secondaryTextColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkCanvas : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Re-type password',
                        filled: true,
                        fillColor: isDark ? AppTheme.darkCanvas : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Driver Profile Picture Center Block
                    Text(
                      'Driver Profile Picture',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primaryGreen, width: 3),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundImage: _pickedImageFile != null
                                      ? FileImage(_pickedImageFile!) as ImageProvider
                                      : NetworkImage(accountPhotoUrl),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _pickImageFromGallery,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Symbols.photo_camera, size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Symbols.account_circle, size: 16, color: AppTheme.primaryGreen),
                                label: const Text('Use Account Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.primaryGreen),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _pickedImageFile = null;
                                  });
                                },
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Symbols.upload, size: 16, color: Colors.white),
                                label: const Text('Upload Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: _pickImageFromGallery,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Handle Nickname
                    Text(
                      'Navigator Handle / Nickname',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nicknameController,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Symbols.badge, size: 20),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkCanvas : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Emergency Highway Contact
                    Text(
                      'Emergency SOS Highway Contact',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emergencyContactController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: primaryTextColor, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Symbols.phone_in_talk, size: 20),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkCanvas : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save & Continue Button
                    ElevatedButton(
                      onPressed: () async {
                        final pass = _passwordController.text.trim();
                        final confirmPass = _confirmPasswordController.text.trim();

                        if (pass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password must be at least 6 characters long.'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (pass != confirmPass) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match. Please check again.'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final photoUrlToSave = _pickedImageFile != null
                            ? _pickedImageFile!.path
                            : accountPhotoUrl;

                        await authCtrl.completeProfileWithPassword(
                          password: pass,
                          nickname: _nicknameController.text.trim().isNotEmpty
                              ? _nicknameController.text.trim()
                              : 'Bengal Navigator',
                          avatarUrl: photoUrlToSave,
                          emergencyContact: _emergencyContactController.text.trim(),
                        );

                        if (context.mounted) {
                          context.go(AppRoutes.map);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save & Explore Map',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Symbols.arrow_forward, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
