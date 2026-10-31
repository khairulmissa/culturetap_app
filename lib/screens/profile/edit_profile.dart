import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/database_service.dart'; 

class EditProfileScreen extends StatefulWidget {
  final User currentUser;
  
  const EditProfileScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService(); 
  
  late String _fullName;
  late String _email;
  late String _phone;
  late String _nationality;
  late String _preferences;
  bool _isSaving = false; 

  @override
  void initState() {
    super.initState();
    _fullName = widget.currentUser.name;
    _email = widget.currentUser.email;
    _phone = widget.currentUser.phone ?? '';
    _nationality = widget.currentUser.nationality ?? '';
    _preferences = widget.currentUser.preferences ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
        actions: [
          IconButton(
            icon: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile, 
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              _buildProfilePicture(),
              const SizedBox(height: 30),
              
              // Form Fields
              _buildTextField(
                label: 'Full Name',
                initialValue: _fullName,
                icon: Icons.person,
                onChanged: (value) => _fullName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                label: 'Email Address',
                initialValue: _email,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => _email = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              _buildTextField(
                label: 'Phone Number',
                initialValue: _phone,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                onChanged: (value) => _phone = value,
              ),
              
              _buildTextField(
                label: 'Nationality',
                initialValue: _nationality,
                icon: Icons.flag,
                onChanged: (value) => _nationality = value,
              ),
              
              _buildTextField(
                label: 'Cultural Interests',
                initialValue: _preferences,
                icon: Icons.interests,
                maxLines: 3,
                onChanged: (value) => _preferences = value,
                helperText: 'Separate interests with commas',
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[800],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Reset Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _resetForm, 
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.purple[800]!),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Reset Changes',
                    style: TextStyle(color: Colors.purple[800]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple[100],
                border: Border.all(color: Colors.purple[800]!, width: 3),
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.purple,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple[800],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  onPressed: _changeProfilePicture,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _changeProfilePicture,
          child: Text(
            'Change Profile Picture',
            style: TextStyle(color: Colors.purple[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData icon,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType = TextInputType.text,
    int maxLines = 1,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.purple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          helperText: helperText,
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  void _changeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture change feature coming soon')),
    );
  }

  void _saveProfile() async { 
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      // UPDATE USER DALAM SQLITE
      final updatedUser = widget.currentUser.copyWith(
        name: _fullName,
        email: _email,
        phone: _phone.isEmpty ? null : _phone,
        nationality: _nationality.isEmpty ? null : _nationality,
        preferences: _preferences.isEmpty ? null : _preferences,
      );

      // SIMPAN KE DATABASE
      final success = await _dbService.updateUser(updatedUser);
      
      if (success > 0) {
        print('✅ Profile updated successfully in SQLite');
        
        // KEMBALIKAN USER YANG SUDAH DIUPDATE
        Navigator.pop(context, updatedUser);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to update profile in database');
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _fullName = widget.currentUser.name;
      _email = widget.currentUser.email;
      _phone = widget.currentUser.phone ?? '';
      _nationality = widget.currentUser.nationality ?? '';
      _preferences = widget.currentUser.preferences ?? '';
    });
  }
}