import 'package:flutter/material.dart';
import '../services/admin_data_service.dart';
import '../services/admin_auth_service.dart';
import '../utils/responsive_helper.dart';

class AdminCreateUserScreen extends StatefulWidget {
  @override
  _AdminCreateUserScreenState createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _houseNameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AdminAuthService.extendSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New User',
          style: TextStyle(
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF1565C0),
        elevation: 2,
      ),
      body: Container(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getCardMaxWidth(context),
              ),
              child: Card(
                elevation: ResponsiveHelper.isMobile(context) ? 4 : 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 24 : 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF1565C0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_add,
                                size: ResponsiveHelper.isMobile(context) ? 32 : 40,
                                color: Color(0xFF1565C0),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create New User',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getTitleFontSize(context),
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                    Text(
                                      'Add a new user to the system',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),

                        // Full Name Field
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter the user\'s name';
                            }
                            if (value!.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 20),

                        // Phone Number Field
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter phone number';
                            }
                            if (value!.length < 10) {
                              return 'Phone number must be at least 10 digits';
                            }
                            // Simple phone validation
                            if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 20),

                        // Password Field
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock,
                          isPassword: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a password';
                            }
                            if (value!.length < 4) {
                              return 'Password must be at least 4 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 20),

                        // House Name Field (Optional)
                        _buildTextField(
                          controller: _houseNameController,
                          label: 'House Name (Optional)',
                          icon: Icons.home,
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 24, tablet: 32, desktop: 40)),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getBodyFontSize(context),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                  side: BorderSide(color: Colors.grey[400]!),
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveHelper.isMobile(context) ? 14 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _createUser,
                                child: _isLoading
                                    ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_add, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Create User',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1565C0),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveHelper.isMobile(context) ? 14 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Info Text
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue[600],
                                  size: 20
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'The new user can immediately log in with the provided phone number and password.',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: ResponsiveHelper.getBodyFontSize(context),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.getBodyFontSize(context),
        ),
        prefixIcon: Icon(
          icon,
          color: Color(0xFF1565C0),
          size: ResponsiveHelper.isMobile(context) ? 20 : 24,
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            size: ResponsiveHelper.isMobile(context) ? 20 : 24,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: ResponsiveHelper.isMobile(context) ? 12 : 16,
        ),
      ),
    );
  }

  void _createUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool success = await AdminDataService.createUser(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          houseName: _houseNameController.text.trim(),
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('User "${_nameController.text}" created successfully!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Clear form
          _nameController.clear();
          _phoneController.clear();
          _passwordController.clear();
          _houseNameController.clear();

          // Optionally navigate back
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          throw Exception('Failed to create user');
        }
      } catch (e) {
        String errorMessage = 'Failed to create user';
        if (e.toString().contains('Phone number already registered')) {
          errorMessage = 'Phone number is already registered';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _houseNameController.dispose();
    super.dispose();
  }
}
