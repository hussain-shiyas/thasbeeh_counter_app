import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_helper.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _name = '';
  String _phone = '';
  String _houseName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? '';
      _phone = prefs.getString('user_phone') ?? '';
      _houseName = prefs.getString('user_house') ?? 'Not provided';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        backgroundColor: Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: ResponsiveHelper.getScreenPadding(context),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: ResponsiveHelper.isMobile(context) ? 40 : 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: ResponsiveHelper.isMobile(context) ? 48 : 60,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _name,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _phone,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Account Details
            Container(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.person,
                        title: 'Full Name',
                        value: _name,
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.phone,
                        title: 'Phone Number',
                        value: _phone,
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.home,
                        title: 'House Name',
                        value: _houseName,
                      ),
                      SizedBox(height: 32),

                      // Action Cards
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.history, color: Color(0xFF2196F3)),
                              title: Text('View Count History'),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () => Navigator.pushNamed(context, '/count-list'),
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.dashboard, color: Color(0xFF2196F3)),
                              title: Text('Go to Dashboard'),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () => Navigator.pushNamed(context, '/dashboard'),
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.logout, color: Colors.red),
                              title: Text('Logout'),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: _showLogoutDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Color(0xFF2196F3), size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}
