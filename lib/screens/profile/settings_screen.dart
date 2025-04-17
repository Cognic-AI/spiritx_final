import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';
import 'package:sri_lanka_sports_app/widgets/custom_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  bool _locationEnabled = true;

  final List<String> _availableLanguages = [
    'English',
    'Sinhala',
    'Tamil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            _buildSectionHeader('Account Settings'),
            _buildSettingItem(
              title: 'Reset Password',
              icon: Icons.lock_reset,
              onTap: _showResetPasswordDialog,
            ),
            _buildSettingItem(
              title: 'Email Verification',
              icon: Icons.email,
              onTap: () {
                // Show email verification dialog
                _showEmailVerificationDialog();
              },
            ),

            const Divider(),

            // Notification Settings
            _buildSectionHeader('Notification Settings'),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive updates about events and news'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                // Save notification settings
                _saveNotificationSettings(value);
              },
              secondary: const Icon(Icons.notifications),
            ),

            const Divider(),

            // Appearance Settings
            _buildSectionHeader('Appearance'),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme throughout the app'),
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                // Save theme settings
                _saveThemeSettings(value);
              },
              secondary: const Icon(Icons.dark_mode),
            ),

            const Divider(),

            // Language Settings
            _buildSectionHeader('Language'),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('App Language'),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showLanguageSelectionDialog,
            ),

            const Divider(),

            // Privacy Settings
            _buildSectionHeader('Privacy'),
            SwitchListTile(
              title: const Text('Location Services'),
              subtitle: const Text('Allow app to access your location'),
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
                // Save location settings
                _saveLocationSettings(value);
              },
              secondary: const Icon(Icons.location_on),
            ),
            _buildSettingItem(
              title: 'Data Usage',
              icon: Icons.data_usage,
              onTap: () {
                // Show data usage dialog
                _showDataUsageDialog();
              },
            ),

            const Divider(),

            // About
            _buildSectionHeader('About'),
            _buildSettingItem(
              title: 'About Sri Lanka Sports',
              icon: Icons.info,
              onTap: () {
                // Show about dialog
                _showAboutDialog();
              },
            ),
            _buildSettingItem(
              title: 'Terms of Service',
              icon: Icons.description,
              onTap: () {
                // Show terms of service
                _showTermsOfService();
              },
            ),
            _buildSettingItem(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip,
              onTap: () {
                // Show privacy policy
                _showPrivacyPolicy();
              },
            ),
            _buildSettingItem(
              title: 'App Version',
              icon: Icons.android,
              subtitle: 'v1.0.0',
              onTap: null,
            ),

            const SizedBox(height: 32),

            // Clear cache button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Clear Cache',
                icon: Icons.cleaning_services,
                isOutlined: true,
                onPressed: () {
                  // Clear app cache
                  _clearAppCache();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing:
          onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();
    final authService = Provider.of<AuthService>(context, listen: false);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your email address to receive a password reset link.',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your email'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          await authService
                              .resetPassword(emailController.text.trim());

                          if (!context.mounted) return;
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password reset link sent to your email'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: const Text('Send Link'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showEmailVerificationDialog() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to verify your email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool isVerified = user.emailVerified;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Email Verification'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isVerified
                    ? const Text(
                        'Your email has been verified.',
                        style: TextStyle(color: Colors.green),
                      )
                    : const Text(
                        'Your email has not been verified. Please verify your email to access all features.',
                      ),
                const SizedBox(height: 16),
                Text('Email: ${user.email}'),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
              if (!isVerified)
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            await user.sendEmailVerification();

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verification email sent'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text('Send Verification Email'),
                ),
            ],
          );
        });
      },
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _availableLanguages.map((language) {
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  // Save language settings
                  _saveLanguageSettings(value!);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDataUsageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Data Usage'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app uses data for the following purposes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Downloading sports information and news'),
              Text('• Syncing your profile and preferences'),
              Text('• Accessing maps for health centers'),
              Text('• Communicating with the AI assistant'),
              SizedBox(height: 16),
              Text(
                'Data usage can be minimized by:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Downloading content for offline use'),
              Text('• Reducing map quality in settings'),
              Text('• Limiting AI assistant usage on mobile data'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Sri Lanka Sports'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryColor,
                child: Icon(
                  Icons.sports,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Sri Lanka Sports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Version 1.0.0'),
              SizedBox(height: 16),
              Text(
                'This app is designed to help sports enthusiasts and athletes in Sri Lanka discover their potential, find resources, and connect with the sports community.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                '© 2023 Sri Lanka Sports Development',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms of Service'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '1. Acceptance of Terms',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'By accessing or using the Sri Lanka Sports app, you agree to be bound by these Terms of Service.',
                ),
                SizedBox(height: 16),
                Text(
                  '2. User Accounts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
                ),
                SizedBox(height: 16),
                Text(
                  '3. User Content',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'You retain ownership of any content you submit to the app, but grant us a license to use, modify, and display that content in connection with the app.',
                ),
                SizedBox(height: 16),
                Text(
                  '4. Prohibited Activities',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'You agree not to engage in any activity that interferes with or disrupts the app or servers, or violates any applicable laws or regulations.',
                ),
                SizedBox(height: 16),
                Text(
                  '5. Termination',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'We reserve the right to terminate or suspend your account at our sole discretion, without notice, for conduct that we believe violates these Terms of Service or is harmful to other users of the app, us, or third parties, or for any other reason.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '1. Information We Collect',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'We collect information you provide directly to us, such as when you create an account, update your profile, or communicate with us.',
                ),
                SizedBox(height: 16),
                Text(
                  '2. How We Use Your Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'We use the information we collect to provide, maintain, and improve our services, to communicate with you, and to personalize your experience.',
                ),
                SizedBox(height: 16),
                Text(
                  '3. Information Sharing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'We do not share your personal information with third parties except as described in this privacy policy.',
                ),
                SizedBox(height: 16),
                Text(
                  '4. Data Security',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.',
                ),
                SizedBox(height: 16),
                Text(
                  '5. Your Choices',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'You can access, update, or delete your account information at any time through the app settings.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _saveNotificationSettings(bool enabled) {
    // In a real app, this would save to shared preferences or backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications ${enabled ? 'enabled' : 'disabled'}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveThemeSettings(bool darkMode) {
    // In a real app, this would save to shared preferences and update app theme
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${darkMode ? 'Dark' : 'Light'} mode will be applied on restart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveLanguageSettings(String language) {
    // In a real app, this would save to shared preferences and update app language
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $language'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveLocationSettings(bool enabled) {
    // In a real app, this would save to shared preferences and update location permissions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location services ${enabled ? 'enabled' : 'disabled'}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _clearAppCache() {
    // In a real app, this would clear the app cache
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
              'Are you sure you want to clear the app cache? This will not delete your account or personal data.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Clear cache logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
