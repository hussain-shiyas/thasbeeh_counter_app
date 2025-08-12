import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AdminDataService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get all users with their total counts
  static Future<List<Map<String, dynamic>>> getAllUsersWithTotalCounts() async {
    try {
      // Get all users
      DataSnapshot usersSnapshot = await _database.child('users').get();
      DataSnapshot countsSnapshot = await _database.child('counts').get();

      List<Map<String, dynamic>> usersWithCounts = [];

      if (usersSnapshot.exists) {
        Map<dynamic, dynamic> users = usersSnapshot.value as Map<dynamic, dynamic>;
        Map<dynamic, dynamic> counts = countsSnapshot.exists ? countsSnapshot.value as Map<dynamic, dynamic> : {};

        for (var userEntry in users.entries) {
          String userId = userEntry.key;
          Map<String, dynamic> userData = Map<String, dynamic>.from(userEntry.value);

          // Calculate total count for this user
          int totalCount = 0;
          List<Map<String, dynamic>> userCounts = [];

          for (var countEntry in counts.entries) {
            Map<String, dynamic> countData = Map<String, dynamic>.from(countEntry.value);
            if (countData['userId'] == userId) {
              totalCount += (countData['count'] as int? ?? 0);
              userCounts.add({
                'count': countData['count'] ?? 0,
                'date': countData['date'] ?? '',
                'createdAt': countData['createdAt'] ?? '',
              });
            }
          }

          // Sort user counts by date (newest first)
          userCounts.sort((a, b) => b['date'].compareTo(a['date']));

          usersWithCounts.add({
            'userId': userId,
            'name': userData['name'] ?? '',
            'phone': userData['phone'] ?? '',
            'houseName': userData['houseName'] ?? '',
            'totalCount': totalCount,
            'countHistory': userCounts,
            'lastActivity': userCounts.isNotEmpty ? userCounts.first['date'] : 'Never',
          });
        }

        // Sort users by total count (highest first)
        usersWithCounts.sort((a, b) => b['totalCount'].compareTo(a['totalCount']));
      }

      return usersWithCounts;
    } catch (e) {
      print('Error getting users with counts: $e');
      return [];
    }
  }

  // Get top user by period (day, week, month)
  static Future<Map<String, dynamic>?> getTopUserByPeriod(String period) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate;

      switch (period.toLowerCase()) {
        case 'day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }

      String startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      String endDateStr = DateFormat('yyyy-MM-dd').format(now);

      DataSnapshot countsSnapshot = await _database.child('counts').get();
      DataSnapshot usersSnapshot = await _database.child('users').get();

      Map<String, int> userCounts = {};

      if (countsSnapshot.exists) {
        Map<dynamic, dynamic> counts = countsSnapshot.value as Map<dynamic, dynamic>;

        for (var entry in counts.entries) {
          Map<String, dynamic> countData = Map<String, dynamic>.from(entry.value);
          String countDate = countData['date'] ?? '';
          String userId = countData['userId'] ?? '';
          int count = countData['count'] ?? 0;

          if (countDate.compareTo(startDateStr) >= 0 &&
              countDate.compareTo(endDateStr) <= 0) {
            userCounts[userId] = (userCounts[userId] ?? 0) + count;
          }
        }
      }

      // Find user with highest count
      if (userCounts.isEmpty) return null;

      String topUserId = userCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      // Get user details
      if (usersSnapshot.exists) {
        Map<dynamic, dynamic> users = usersSnapshot.value as Map<dynamic, dynamic>;
        if (users.containsKey(topUserId)) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(users[topUserId]);
          return {
            'userId': topUserId,
            'name': userData['name'] ?? '',
            'phone': userData['phone'] ?? '',
            'houseName': userData['houseName'] ?? '',
            'periodCount': userCounts[topUserId] ?? 0,
            'period': period,
          };
        }
      }

      return null;
    } catch (e) {
      print('Error getting top user by period: $e');
      return null;
    }
  }

  // Get admin dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      DataSnapshot usersSnapshot = await _database.child('users').get();
      DataSnapshot countsSnapshot = await _database.child('counts').get();

      int totalUsers = 0;
      int totalCounts = 0;
      int todaysCounts = 0;

      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (usersSnapshot.exists) {
        Map<dynamic, dynamic> users = usersSnapshot.value as Map<dynamic, dynamic>;
        totalUsers = users.length;
      }

      if (countsSnapshot.exists) {
        Map<dynamic, dynamic> counts = countsSnapshot.value as Map<dynamic, dynamic>;

        for (var entry in counts.entries) {
          Map<String, dynamic> countData = Map<String, dynamic>.from(entry.value);
          int count = countData['count'] ?? 0;
          String date = countData['date'] ?? '';

          totalCounts += count;

          if (date == today) {
            todaysCounts += count;
          }
        }
      }

      return {
        'totalUsers': totalUsers,
        'totalCounts': totalCounts,
        'todaysCounts': todaysCounts,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalUsers': 0,
        'totalCounts': 0,
        'todaysCounts': 0,
      };
    }
  }

  // create user
  static Future<bool> createUser({
    required String name,
    required String phone,
    required String password,
    String? houseName,
  }) async {
    try {
      // Check if phone already exists
      DataSnapshot snapshot = await _database
          .child('users')
          .orderByChild('phone')
          .equalTo(phone)
          .get();

      if (snapshot.exists) {
        throw Exception('Phone number already registered');
      }

      // Create new user
      DatabaseReference newUserRef = _database.child('users').push();

      Map<String, dynamic> userData = {
        'name': name,
        'phone': phone,
        'password': password,
        'houseName': houseName ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await newUserRef.set(userData);
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

}
