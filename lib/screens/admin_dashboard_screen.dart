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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    AdminAuthService.extendSession();
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
      appBar: _buildAppBar(),
      drawer: ResponsiveHelper.isMobile(context) ? _buildDrawer() : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ResponsiveHelper.isMobile(context)
          ? _buildMobileLayout()
          : _buildDesktopLayout(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Admin Dashboard',
        style: TextStyle(
          fontSize: ResponsiveHelper.getTitleFontSize(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Color(0xFF1565C0),
      elevation: ResponsiveHelper.isMobile(context) ? 4 : 0,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _loadDashboardData,
          tooltip: 'Refresh Data',
        ),
        if (!ResponsiveHelper.isMobile(context))
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Thasbeeh Counter',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Color(0xFF1565C0)),
            title: Text('Dashboard'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: Color(0xFF1565C0)),
            title: Text('All Users'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin-users');
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add, color: Color(0xFF1565C0)),
            title: Text('Create User'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin-create-user');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          _buildTopUsersSection(),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          _buildTop10UsersSection(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar (for desktop)
        if (ResponsiveHelper.isDesktop(context))
          Container(
            width: 250,
            color: Color(0xFFF8F9FA),
            child: _buildSidebar(),
          ),

        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatisticsSection(),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildTopUsersSection(),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildTop10UsersSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo section
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Color(0xFF1565C0),
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    Text(
                      'Thasbeeh Counter',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32),

          // Navigation items
          _buildSidebarItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            isSelected: true,
            onTap: () {},
          ),
          _buildSidebarItem(
            icon: Icons.people,
            title: 'All Users',
            onTap: () => Navigator.pushNamed(context, '/admin-users'),
          ),
          _buildSidebarItem(
            icon: Icons.person_add,
            title: 'Create User',
            onTap: () => Navigator.pushNamed(context, '/admin-create-user'),
          ),

          Spacer(),

          // Logout button
          _buildSidebarItem(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? Color(0xFF1565C0).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive
                      ? Colors.red
                      : isSelected
                      ? Color(0xFF1565C0)
                      : Colors.grey[600],
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isDestructive
                        ? Colors.red
                        : isSelected
                        ? Color(0xFF1565C0)
                        : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
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
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        SizedBox(height: 16),
        _buildResponsiveGrid(
          children: [
            _buildStatCard(
              'Total Users',
              _dashboardStats['totalUsers']?.toString() ?? '0',
              Icons.people,
              Color(0xFF4CAF50),
            ),
            _buildStatCard(
              'Total Counts',
              NumberFormat('#,###').format(_dashboardStats['totalCounts'] ?? 0),
              Icons.analytics,
              Color(0xFF2196F3),
            ),
            _buildStatCard(
              'Today\'s Counts',
              _dashboardStats['todaysCounts']?.toString() ?? '0',
              Icons.today,
              Color(0xFFFF9800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Users by Period',
          style: TextStyle(
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        SizedBox(height: 16),
        _buildResponsiveGrid(
          children: [
            _buildTopUserCard('Today', _topUserToday, Color(0xFFE91E63)),
            _buildTopUserCard('This Week', _topUserWeek, Color(0xFF9C27B0)),
            _buildTopUserCard('This Month', _topUserMonth, Color(0xFF673AB7)),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid({required List<Widget> children}) {
    if (ResponsiveHelper.isMobile(context)) {
      return Column(
        children: children.map((child) => Container(
          margin: EdgeInsets.only(bottom: 16),
          child: child,
        )).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = ResponsiveHelper.getGridColumns(context);
        if (children.length < columns) {
          columns = children.length;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: ResponsiveHelper.isTablet(context) ? 1.8 : 2.0,
          children: children,
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: ResponsiveHelper.isMobile(context) ? 2 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: ResponsiveHelper.isMobile(context) ? 24 : 28),
                ),
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
                fontSize: ResponsiveHelper.getBodyFontSize(context),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUserCard(String period, Map<String, dynamic>? user, Color color) {
    return Card(
      elevation: ResponsiveHelper.isMobile(context) ? 2 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.star, color: color, size: 20),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (user != null) ...[
              Text(
                user['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                user['phone'] ?? '',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${NumberFormat('#,###').format(user['periodCount'])} counts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: ResponsiveHelper.getBodyFontSize(context) - 1,
                  ),
                ),
              ),
            ] else ...[
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getBodyFontSize(context),
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

  Widget _buildTop10UsersSection() {
    final top10Users = _allUsers.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Top 10 Users',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/admin-users');
              },
              icon: Icon(Icons.people, size: 18),
              label: Text(
                ResponsiveHelper.isMobile(context)
                    ? 'View All'
                    : 'View All ${_allUsers.length} Users',
              ),
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
        SizedBox(height: 16),
        Card(
          elevation: ResponsiveHelper.isMobile(context) ? 2 : 4,
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
                    if (!ResponsiveHelper.isMobile(context)) ...[
                      Text(
                        'Rank',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getBodyFontSize(context),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                    Expanded(
                      flex: ResponsiveHelper.isMobile(context) ? 1 : 3,
                      child: Text(
                        'User Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getBodyFontSize(context),
                        ),
                      ),
                    ),
                    if (!ResponsiveHelper.isMobile(context))
                      Expanded(
                        child: Text(
                          'Total Count',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(width: ResponsiveHelper.isMobile(context) ? 60 : 80),
                  ],
                ),
              ),

              // Users List
              Column(
                children: top10Users.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> user = entry.value;
                  return _buildResponsiveUserRow(user, index + 1);
                }).toList(),
              ),

              // Show more button
              if (_allUsers.length > 10)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin-users');
                        },
                        icon: Icon(Icons.expand_more),
                        label: Text(
                          'Show ${_allUsers.length - 10} more users',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveHelper.getBodyFontSize(context),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveUserRow(Map<String, dynamic> user, int rank) {
    Color rankColor = rank == 1
        ? Color(0xFFFFD700)
        : rank == 2
        ? Color(0xFFC0C0C0)
        : rank == 3
        ? Color(0xFFCD7F32)
        : Colors.grey[600]!;

    if (ResponsiveHelper.isMobile(context)) {
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
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),

            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    user['phone'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${NumberFormat('#,###').format(user['totalCount'])} counts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // History Button
            IconButton(
              onPressed: () => _showUserHistory(user),
              icon: Icon(Icons.history, color: Color(0xFF1565C0)),
              tooltip: 'View History',
            ),
          ],
        ),
      );
    }

    // Desktop/Tablet layout
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
                    fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user['phone'] ?? '',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getBodyFontSize(context),
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
                fontSize: ResponsiveHelper.getSubtitleFontSize(context),
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
            width: ResponsiveHelper.isMobile(context)
                ? MediaQuery.of(context).size.width * 0.9
                : ResponsiveHelper.isTablet(context)
                ? 600
                : 700,
            height: ResponsiveHelper.isMobile(context)
                ? MediaQuery.of(context).size.height * 0.8
                : 600,
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
                                fontSize: ResponsiveHelper.getTitleFontSize(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user['phone'] ?? '',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: ResponsiveHelper.getBodyFontSize(context),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No count history available',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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
                                '${NumberFormat('#,###').format(history['count'])}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                  fontSize: ResponsiveHelper.isMobile(context) ? 12 : 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          title: Text(
                            DateFormat('MMMM dd, yyyy').format(
                              DateTime.parse(history['date']),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveHelper.getBodyFontSize(context),
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('EEEE').format(
                              DateTime.parse(history['date']),
                            ),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: ResponsiveHelper.getBodyFontSize(context) - 2,
                            ),
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
                          fontSize: ResponsiveHelper.getSubtitleFontSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        NumberFormat('#,###').format(user['totalCount']),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getTitleFontSize(context),
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
