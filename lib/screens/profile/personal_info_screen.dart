import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/models/user_model.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';
import 'package:sri_lanka_sports_app/widgets/custom_text_field.dart';

class PersonalInfoScreen extends StatefulWidget {
  final UserModel userModel;

  const PersonalInfoScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _emergencyContactController;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel.name);
    _emailController = TextEditingController(text: widget.userModel.email);

    // Initialize with default values if not available
    _phoneController = TextEditingController(
        text: widget.userModel.phone ?? 'Not defined yet');
    _addressController = TextEditingController(
        text: widget.userModel.address ?? 'Not defined yet');
    _dateOfBirthController = TextEditingController(
        text: widget.userModel.dateOfBirth ?? 'Not defined yet');
    _heightController = TextEditingController(
        text: widget.userModel.height?.toString() ?? 'Not defined yet');
    _weightController = TextEditingController(
        text: widget.userModel.weight?.toString() ?? 'Not defined yet');
    _emergencyContactController = TextEditingController(
        text: widget.userModel.emergencyContact ?? 'Not defined yet');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Extract values, handling the "Not defined yet" default text
      String? phone = _phoneController.text;
      if (phone == 'Not defined yet') phone = null;

      String? address = _addressController.text;
      if (address == 'Not defined yet') address = null;

      String? dateOfBirth = _dateOfBirthController.text;
      if (dateOfBirth == 'Not defined yet') dateOfBirth = null;

      String? heightText = _heightController.text;
      int? height;
      if (heightText != 'Not defined yet') {
        height = int.tryParse(heightText);
      }

      String? weightText = _weightController.text;
      int? weight;
      if (weightText != 'Not defined yet') {
        weight = int.tryParse(weightText);
      }

      String? emergencyContact = _emergencyContactController.text;
      if (emergencyContact == 'Not defined yet') emergencyContact = null;

      await authService.updateUserProfile(
        name: _nameController.text,
        phone: phone,
        address: address,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
        emergencyContact: emergencyContact,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _isLoading ? null : _toggleEditing,
            tooltip: _isEditing ? 'Cancel' : 'Edit',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field (read-only)
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Phone field
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    CustomTextField(
                      controller: _addressController,
                      labelText: 'Address',
                      prefixIcon: Icons.home,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth field
                    CustomTextField(
                      controller: _dateOfBirthController,
                      labelText: 'Date of Birth',
                      prefixIcon: Icons.calendar_today,
                      enabled: _isEditing,
                      onSuffixIconPressed: _isEditing
                          ? () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now()
                                    .subtract(const Duration(days: 365 * 18)),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );

                              if (date != null) {
                                setState(() {
                                  _dateOfBirthController.text =
                                      '${date.day}/${date.month}/${date.year}';
                                });
                              }
                            }
                          : null,
                      suffixIcon: Icons.calendar_month,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Physical Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Height field
                    CustomTextField(
                      controller: _heightController,
                      labelText: 'Height (cm)',
                      prefixIcon: Icons.height,
                      keyboardType: TextInputType.number,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Weight field
                    CustomTextField(
                      controller: _weightController,
                      labelText: 'Weight (kg)',
                      prefixIcon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Emergency Contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emergency Contact field
                    CustomTextField(
                      controller: _emergencyContactController,
                      labelText: 'Emergency Contact',
                      prefixIcon: Icons.emergency,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 24),

                    if (_isEditing)
                      CustomButton(
                        text: 'Save Changes',
                        isLoading: _isLoading,
                        onPressed: _saveChanges,
                      ),

                    if (!_isEditing &&
                        widget.userModel.role == 'sportsperson') ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Complete Your Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'As a sportsperson, having complete profile information helps us provide better recommendations and services. Please update any missing information.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
