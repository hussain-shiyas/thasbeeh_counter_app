import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../utils/responsive_helper.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _countController = TextEditingController();
  String _userName = '';
  String _userId = '';
  int _todayCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
      _userId = prefs.getString('user_id') ?? '';
    });

    // Load today's count from Firebase
    if (_userId.isNotEmpty) {
      await _loadTodayCount();
    }
  }

  Future<void> _loadTodayCount() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int todayCount = await AuthService.getTodayCount(_userId, today);
    setState(() {
      _todayCount = todayCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFF2196F3),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'count-list':
                  Navigator.pushNamed(context, '/count-list');
                  break;
                case 'account':
                  Navigator.pushNamed(context, '/account');
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'count-list', child: Text('Count History')),
              PopupMenuItem(value: 'account', child: Text('Account')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Container(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $_userName!',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Today's Count Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.today, color: Color(0xFF2196F3), size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Today\'s Total Count',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: ResponsiveHelper.isMobile(context) ? 80 : 100,
                          height: ResponsiveHelper.isMobile(context) ? 80 : 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2196F3).withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              '$_todayCount',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.isMobile(context) ? 28 : 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ),
                        ),
                        if (_todayCount > 0) ...[
                          SizedBox(height: 8),
                          Text(
                            'Combined from all entries today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Add Count Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_circle, color: Color(0xFF2196F3), size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Add Count',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enter new count to add to today\'s total',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _countController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter count',
                            hintText: 'Type a number...',
                            prefixIcon: Icon(Icons.numbers, color: Color(0xFF2196F3)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF2196F3), width: 2),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addCount,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add),
                                SizedBox(width: 8),
                                Text(_todayCount > 0 ? 'Add to Today\'s Total' : 'Save Count'),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addCount() async {
    if (_countController.text.isNotEmpty && _userId.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final count = int.tryParse(_countController.text) ?? 0;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (count <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid number greater than 0'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      bool success = await AuthService.saveCount(
        userId: _userId,
        count: count,
        date: today,
      );

      if (success) {
        // Reload today's count to show updated total
        await _loadTodayCount();

        _countController.clear();

        String message = _todayCount == count
            ? 'Count saved successfully!'
            : 'Count added! New total: $_todayCount';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving count. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
