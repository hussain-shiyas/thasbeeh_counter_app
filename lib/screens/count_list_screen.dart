import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../utils/responsive_helper.dart';

class CountListScreen extends StatefulWidget {
  @override
  _CountListScreenState createState() => _CountListScreenState();
}

class _CountListScreenState extends State<CountListScreen> {
  List<Map<String, dynamic>> _countData = [];
  bool _isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadCountData();
  }

  void _loadCountData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? '';

    if (_userId.isNotEmpty) {
      List<Map<String, dynamic>> counts = await AuthService.getUserCounts(_userId);

      // Transform data to match your original format
      List<Map<String, dynamic>> transformedData = [];
      for (var count in counts) {
        try {
          DateTime date = DateTime.parse(count['date']);
          transformedData.add({
            'date': date,
            'count': count['count'] ?? 0,
            'dateString': count['date'],
          });
        } catch (e) {
          print('Error parsing date: ${count['date']}');
        }
      }

      // Sort by date (newest first)
      transformedData.sort((a, b) => b['date'].compareTo(a['date']));

      setState(() {
        _countData = transformedData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Count History'),
        backgroundColor: Color(0xFF2196F3),
      ),
      body: Container(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
                      ),
                    ),
                    child: ResponsiveHelper.isMobile(context)
                        ? Column(
                      children: [
                        _buildSummaryItem('Total Records', '${_countData.length}'),
                        SizedBox(height: 16),
                        _buildSummaryItem('Total Count', '${_countData.fold(0, (sum, item) => sum + (item['count'] as int))}'),
                      ],
                    )
                        : Row(
                      children: [
                        Icon(Icons.history, color: Colors.white, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryItem('Total Records', '${_countData.length}'),
                        ),
                        Expanded(
                          child: _buildSummaryItem('Total Count', '${_countData.fold(0, (sum, item) => sum + (item['count'] as int))}'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Count List
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _countData.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No count records yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start adding counts from the dashboard',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: _countData.length,
                    itemBuilder: (context, index) {
                      final item = _countData[index];
                      final date = item['date'] as DateTime;
                      final count = item['count'] as int;
                      final isToday = DateFormat('yyyy-MM-dd').format(date) ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now());

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 12 : 16),
                          leading: Container(
                            width: ResponsiveHelper.isMobile(context) ? 40 : 50,
                            height: ResponsiveHelper.isMobile(context) ? 40 : 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? Color(0xFF2196F3)
                                  : Color(0xFF2196F3).withOpacity(0.1),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('dd').format(date),
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? Colors.white
                                      : Color(0xFF2196F3),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            DateFormat('EEEE, MMM dd, yyyy').format(date),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                            ),
                          ),
                          subtitle: isToday
                              ? Text(
                            'Today',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                              : null,
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isMobile(context) ? 8 : 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: ResponsiveHelper.isMobile(context)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
