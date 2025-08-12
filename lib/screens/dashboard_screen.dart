import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../utils/responsive_helper.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final _countController = TextEditingController();
  String _userName = '';
  String _userId = '';
  int _todayCount = 0;
  bool _isLoading = false;

  // Counter feature variables
  int _currentCounter = 0;
  bool _isCounterLoading = false;
  late AnimationController _counterAnimationController;
  late Animation<double> _counterScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeCounterAnimation();
  }

  void _initializeCounterAnimation() {
    _counterAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _counterScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _counterAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
      _userId = prefs.getString('user_id') ?? '';
    });

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(),
                  SizedBox(height: 24),

                  // Today's Count Card
                  _buildTodayCountCard(),
                  SizedBox(height: 24),

                  // Counter Feature Card
                  _buildCounterCard(),
                  SizedBox(height: 24),

                  // Add Count Card (Manual Entry)
                  _buildManualCountCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
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
    );
  }

  Widget _buildTodayCountCard() {
    return Card(
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
    );
  }

  Widget _buildCounterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.ads_click, color: Color(0xFF4CAF50), size: 28),
                SizedBox(width: 12),
                Text(
                  'Digital Counter',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isMobile(context) ? 18 : 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Tap to increment, then add to today\'s count',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),

            // Counter Display
            Center(
              child: AnimatedBuilder(
                animation: _counterScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _counterScaleAnimation.value,
                    child: Container(
                      width: ResponsiveHelper.isMobile(context) ? 120 : 150,
                      height: ResponsiveHelper.isMobile(context) ? 120 : 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(75),
                          onTap: _incrementCounter,
                          child: Center(
                            child: Text(
                              '$_currentCounter',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.isMobile(context) ? 32 : 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Counter Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentCounter > 0 ? _resetCounter : null,
                    icon: Icon(Icons.refresh, size: 20),
                    label: Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: (_currentCounter > 0 && !_isCounterLoading)
                        ? _addCounterToTotal
                        : null,
                    icon: _isCounterLoading
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(Icons.add, size: 20),
                    label: Text(_isCounterLoading ? 'Adding...' : 'Add to Total'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualCountCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Color(0xFF2196F3), size: 28),
                SizedBox(width: 12),
                Text(
                  'Manual Entry',
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
              'Enter a custom count directly',
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
                onPressed: _isLoading ? null : _addManualCount,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Save Count'),
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
    );
  }

  void _incrementCounter() {
    setState(() {
      _currentCounter++;
    });

    // Play animation
    _counterAnimationController.forward().then((_) {
      _counterAnimationController.reverse();
    });

    // Haptic feedback
    // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback
  }

  void _resetCounter() {
    setState(() {
      _currentCounter = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Counter reset to 0'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addCounterToTotal() async {
    if (_currentCounter > 0 && _userId.isNotEmpty) {
      setState(() {
        _isCounterLoading = true;
      });

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      bool success = await AuthService.saveCount(
        userId: _userId,
        count: _currentCounter,
        date: today,
      );

      if (success) {
        // Reload today's count to show updated total
        await _loadTodayCount();

        final previousCount = _currentCounter;

        // Reset counter after successful save
        setState(() {
          _currentCounter = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $previousCount to today\'s total! Counter reset.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding count. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isCounterLoading = false;
      });
    }
  }

  void _addManualCount() async {
    if (_countController.text.isNotEmpty && _userId.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final newCount = int.tryParse(_countController.text) ?? 0;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final previousTodayCount = _todayCount;

      if (newCount <= 0) {
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
        count: newCount,
        date: today,
      );

      if (success) {
        await _loadTodayCount();

        String message;
        if (previousTodayCount > 0) {
          message = 'Added $newCount to today\'s count. Total: $_todayCount';
        } else {
          message = 'Count saved successfully! Today\'s total: $_todayCount';
        }

        _countController.clear();
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
    await AuthService.clearLoginState();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _counterAnimationController.dispose();
    _countController.dispose();
    super.dispose();
  }
}
