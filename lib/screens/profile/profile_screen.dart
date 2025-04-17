import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/screens/auth/login_screen.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  
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
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userModel = authService.userModel;
    final isSportsperson = userModel?.role == 'sportsperson';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  backgroundImage: userModel?.profileImageUrl != null
                      ? NetworkImage(userModel!.profileImageUrl!)
                      : null,
                  child: userModel?.profileImageUrl == null
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
                    onPressed: _isLoading ? null : _pickProfileImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // User name
            Text(
              userModel?.name ?? 'User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            
            // User email
            Text(
              userModel?.email ?? 'user@example.com',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            
            // User role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSportsperson ? AppTheme.primaryColor : AppTheme.secondaryColor,
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
            const SizedBox(height: 32),
            
            // Profile sections
            const Divider(),
            _buildProfileSection(
              title: 'Personal Information',
              icon: Icons.person,
              onTap: () {
                // Navigate to personal info screen
              },
            ),
            const Divider(),
            _buildProfileSection(
              title: 'Interests & Preferences',
              icon: Icons.favorite,
              onTap: () {
                // Navigate to interests screen
              },
            ),
            const Divider(),
            _buildProfileSection(
              title: 'Achievements',
              icon: Icons.emoji_events,
              onTap: () {
                // Navigate to achievements screen
              },
            ),
            const Divider(),
            _buildProfileSection(
              title: 'Settings',
              icon: Icons.settings,
              onTap: () {
                // Navigate to settings screen
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
          ],
        ),
      ),
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
}
