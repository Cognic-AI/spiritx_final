import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/models/user_model.dart';
import 'package:sri_lanka_sports_app/screens/auth/login_screen.dart';
import 'package:sri_lanka_sports_app/screens/profile/personal_info_screen.dart';
import 'package:sri_lanka_sports_app/screens/profile/settings_screen.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
// import 'package:sri_lanka_sports_app/services/dummy_data_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool _isLoading = false;
  // bool _isGeneratingDummyData = false;
  final ImagePicker _picker = ImagePicker();
  // final DummyDataService _dummyDataService = DummyDataService();

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });

      // Update profile image
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        setState(() {
          _isLoading = true;
        });

        await authService.updateUserProfile(
          profileImage: _profileImage,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  // Future<void> _generateDummyData() async {
  //   try {
  //     setState(() {
  //       _isGeneratingDummyData = true;
  //     });

  //     await _dummyDataService.generateDummyData();

  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Dummy data generated successfully'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error generating dummy data: ${e.toString()}'),
  //         backgroundColor: AppTheme.errorColor,
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       _isGeneratingDummyData = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userModel = authService.userModel;

    if (userModel == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    final isSportsperson = userModel.role == 'sportsperson';

    return
        // Scaffold(
        //   appBar: AppBar(
        //     title: const Text('Profile'),
        //     actions: [
        //       IconButton(
        //         icon: const Icon(Icons.logout),
        //         onPressed: _isLoading ? null : _signOut,
        //         tooltip: 'Sign Out',
        //       ),
        //     ],
        //   ),
        //   body:
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile image
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: userModel.profileImageUrl != null
                              ? NetworkImage(userModel.profileImageUrl!)
                              : null,
                          child: userModel.profileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryColor,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: _pickProfileImage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // User name
                    Text(
                      userModel.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // User email
                    Text(
                      userModel.email,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // User role and verification status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSportsperson
                                ? AppTheme.primaryColor
                                : AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            isSportsperson ? 'Sports Person' : 'Student',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSportsperson) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: userModel.isVerified
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              userModel.isVerified
                                  ? 'Verified'
                                  : 'Pending Verification',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Generate dummy data button
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.amber.withOpacity(0.2),
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.amber),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'Developer Tools',
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       const Text(
                    //         'Generate dummy data for testing purposes. This will create sample data for all collections in the database.',
                    //       ),
                    //       const SizedBox(height: 16),
                    //       CustomButton(
                    //         text: _isGeneratingDummyData
                    //             ? 'Generating Data...'
                    //             : 'Generate Dummy Data',
                    //         icon: Icons.data_array,
                    //         isLoading: _isGeneratingDummyData,
                    //         onPressed: _generateDummyData,
                    //         color: Colors.amber[700],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 24),

                    // Profile sections
                    const Divider(),
                    _buildProfileSection(
                      title: 'Personal Information',
                      icon: Icons.person,
                      onTap: () {
                        _navigateToPersonalInfo(userModel);
                      },
                    ),
                    const Divider(),
                    if (isSportsperson) ...[
                      _buildProfileSection(
                        title: 'Verification Status',
                        icon: Icons.verified_user,
                        onTap: () {
                          _showVerificationStatus(userModel);
                        },
                      ),
                      const Divider(),
                    ],
                    _buildProfileSection(
                      title: 'Settings',
                      icon: Icons.settings,
                      onTap: () {
                        _navigateToSettings();
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 32),

                    // Sign out button
                    CustomButton(
                      text: 'Sign Out',
                      icon: Icons.logout,
                      onPressed: _signOut,
                    ),
                    const SizedBox(height: 16),

                    // Delete account button
                    TextButton(
                      onPressed: () {
                        _showDeleteAccountConfirmation();
                      },
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                // ),
              );
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _navigateToPersonalInfo(UserModel userModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalInfoScreen(userModel: userModel),
      ),
    );
  }

  void _showVerificationStatus(UserModel userModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verification Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    userModel.isVerified ? Icons.verified_user : Icons.pending,
                    color: userModel.isVerified ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userModel.isVerified ? 'Verified' : 'Pending Verification',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          userModel.isVerified ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userModel.isVerified
                    ? 'Your account has been verified. You have full access to all features.'
                    : 'Your account is pending verification. Some features may be limited until verification is complete.',
              ),
              if (!userModel.isVerified) ...[
                const SizedBox(height: 16),
                const Text(
                  'We are reviewing your NIC information. This process usually takes 1-2 business days.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
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
          ],
        );
      },
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
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
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.deleteAccount();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
