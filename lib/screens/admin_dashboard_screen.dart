import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/admin_auth_service.dart';
import '../services/admin_data_service.dart';
import '../utils/responsive_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _allUsers = [];
  Map<String, dynamic>? _topUserToday;
  Map<String, dynamic>? _topUserWeek;
  Map<String, dynamic>? _topUserMonth;
  bool _isLoading = true;
  String _selectedPeriod = 'day';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await AdminDataService.getDashboardStats();
      final users = await AdminDataService.getAllUsersWithTotalCounts();
      final topToday = await AdminDataService.getTopUserByPeriod('day');
      final topWeek = await AdminDataService.getTopUserByPeriod('week');
      final topMonth = await AdminDataService.getTopUserByPeriod('month');

      setState(() {
        _dashboardStats = stats;
        _allUsers = users;
        _topUserToday = topToday;
        _topUserWeek = topWeek;
        _topUserMonth = topMonth;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Color(0xFF1565C0),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  _buildStatisticsSection(),
                  SizedBox(height: 24),

                  // Top Users by Period
                  _buildTopUsersSection(),
                  SizedBox(height: 24),

                  // All Users List
                  _buildAllUsersSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview Statistics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        SizedBox(height: 16),
        ResponsiveHelper.isMobile(context)
            ? Column(children: _buildStatCards())
            : Row(children: _buildStatCards()),
      ],
    );
  }

  List<Widget> _buildStatCards() {
    return [
      Expanded(
        child: _buildStatCard(
          'Total Users',
          _dashboardStats['totalUsers']?.toString() ?? '0',
          Icons.people,
          Color(0xFF4CAF50),
        ),
      ),
      SizedBox(width: ResponsiveHelper.isMobile(context) ? 0 : 16, height: ResponsiveHelper.isMobile(context) ? 16 : 0),
      Expanded(
        child: _buildStatCard(
          'Total Counts',
          NumberFormat('#,###').format(_dashboardStats['totalCounts'] ?? 0),
          Icons.analytics,
          Color(0xFF2196F3),
        ),
      ),
      SizedBox(width: ResponsiveHelper.isMobile(context) ? 0 : 16, height: ResponsiveHelper.isMobile(context) ? 16 : 0),
      Expanded(
        child: _buildStatCard(
          'Today\'s Counts',
          _dashboardStats['todaysCounts']?.toString() ?? '0',
          Icons.today,
          Color(0xFFFF9800),
        ),
      ),
    ];
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Users by Period',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        SizedBox(height: 16),
        ResponsiveHelper.isMobile(context)
            ? Column(children: _buildTopUserCards())
            : Row(children: _buildTopUserCards()),
      ],
    );
  }

  List<Widget> _buildTopUserCards() {
    return [
      Expanded(
        child: _buildTopUserCard('Today', _topUserToday, Color(0xFFE91E63)),
      ),
      SizedBox(width: ResponsiveHelper.isMobile(context) ? 0 : 16, height: ResponsiveHelper.isMobile(context) ? 16 : 0),
      Expanded(
        child: _buildTopUserCard('This Week', _topUserWeek, Color(0xFF9C27B0)),
      ),
      SizedBox(width: ResponsiveHelper.isMobile(context) ? 0 : 16, height: ResponsiveHelper.isMobile(context) ? 16 : 0),
      Expanded(
        child: _buildTopUserCard('This Month', _topUserMonth, Color(0xFF673AB7)),
      ),
    ];
  }

  Widget _buildTopUserCard(String period, Map<String, dynamic>? user, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: color, size: 24),
                SizedBox(width: 8),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (user != null) ...[
              Text(
                user['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                user['phone'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${user['periodCount']} counts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ] else ...[
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'All Users (Ranked by Total Count)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            Spacer(),
            Text(
              '${_allUsers.length} users',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1565C0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Rank',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'User Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Total Count',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 80),
                  ],
                ),
              ),

              // User List
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  final user = _allUsers[index];
                  return _buildUserRow(user, index + 1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user, int rank) {
    Color rankColor = rank == 1
        ? Color(0xFFFFD700)
        : rank == 2
        ? Color(0xFFC0C0C0)
        : rank == 3
        ? Color(0xFFCD7F32)
        : Colors.grey[600]!;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),

          // User Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user['phone'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (user['houseName']?.isNotEmpty ?? false) ...[
                  SizedBox(height: 2),
                  Text(
                    user['houseName'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Total Count
          Expanded(
            child: Text(
              NumberFormat('#,###').format(user['totalCount'] ?? 0),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // View History Button
          ElevatedButton(
            onPressed: () => _showUserHistory(user),
            child: Text('History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserHistory(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: ResponsiveHelper.isDesktop(context) ? 600 : double.infinity,
            height: 500,
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF1565C0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? 'Unknown User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user['phone'] ?? '',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // History List
                Expanded(
                  child: user['countHistory'].isEmpty
                      ? Center(
                    child: Text(
                      'No count history available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: user['countHistory'].length,
                    itemBuilder: (context, index) {
                      final history = user['countHistory'][index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                '${history['count']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            DateFormat('MMMM dd, yyyy').format(
                              DateTime.parse(history['date']),
                            ),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormat('EEEE').format(
                              DateTime.parse(history['date']),
                            ),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Total Summary
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Count:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        NumberFormat('#,###').format(user['totalCount']),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
      },
    );
  }

  void _logout() async {
    await AdminAuthService.adminLogout();
    Navigator.pushReplacementNamed(context, '/admin-login');
  }
}
