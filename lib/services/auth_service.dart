import 'package:firebase_database/firebase_database.dart';

class AuthService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Register new user
  static Future<Map<String, dynamic>?> registerUser({
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
      String userId = newUserRef.key!;

      Map<String, dynamic> userData = {
        'name': name,
        'phone': phone,
        'password': password,
        'houseName': houseName ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await newUserRef.set(userData);
      userData['userId'] = userId;

      return userData;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Login user
  static Future<Map<String, dynamic>?> loginUser({
    required String phone,
    required String password,
  }) async {
    try {
      DataSnapshot snapshot = await _database
          .child('users')
          .orderByChild('phone')
          .equalTo(phone)
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

        for (var entry in users.entries) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(entry.value);

          if (userData['password'] == password) {
            userData['userId'] = entry.key;
            return userData;
          }
        }
      }

      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Save count with accumulation logic
  static Future<bool> saveCount({
    required String userId,
    required int count,
    required String date,
  }) async {
    try {
      DatabaseReference countRef = _database.child('counts');

      // Check if there's already a count for this user and date
      DataSnapshot existingSnapshot = await countRef
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      String? existingCountId;
      int existingCount = 0;

      if (existingSnapshot.exists) {
        Map<dynamic, dynamic> counts = existingSnapshot.value as Map<dynamic, dynamic>;

        // Look for existing count on the same date
        for (var entry in counts.entries) {
          Map<String, dynamic> countData = Map<String, dynamic>.from(entry.value);
          if (countData['date'] == date && countData['userId'] == userId) {
            existingCountId = entry.key;
            existingCount = countData['count'] ?? 0;
            break;
          }
        }
      }

      if (existingCountId != null) {
        // Update existing count by adding the new count
        int totalCount = existingCount + count;
        await countRef.child(existingCountId).update({
          'count': totalCount,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        // Create new count entry
        DatabaseReference newCountRef = countRef.push();
        await newCountRef.set({
          'userId': userId,
          'count': count,
          'date': date,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      print('Save count error: $e');
      return false;
    }
  }

  // Get user counts
  static Future<List<Map<String, dynamic>>> getUserCounts(String userId) async {
    try {
      DataSnapshot snapshot = await _database
          .child('counts')
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> counts = snapshot.value as Map<dynamic, dynamic>;

        List<Map<String, dynamic>> countList = [];
        for (var entry in counts.entries) {
          Map<String, dynamic> countData = Map<String, dynamic>.from(entry.value);
          countData['countId'] = entry.key;
          countList.add(countData);
        }

        // Sort by date (newest first)
        countList.sort((a, b) => b['date'].compareTo(a['date']));
        return countList;
      }

      return [];
    } catch (e) {
      print('Get counts error: $e');
      return [];
    }
  }

  // GET TODAY'S COUNT - This is the missing method
  static Future<int> getTodayCount(String userId, String date) async {
    try {
      DataSnapshot snapshot = await _database
          .child('counts')
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> counts = snapshot.value as Map<dynamic, dynamic>;

        // Look for count on the specified date
        for (var entry in counts.entries) {
          Map<String, dynamic> countData = Map<String, dynamic>.from(entry.value);
          if (countData['date'] == date && countData['userId'] == userId) {
            return countData['count'] ?? 0;
          }
        }
      }

      return 0; // Return 0 if no count found for this date
    } catch (e) {
      print('Get today count error: $e');
      return 0;
    }
  }
}
