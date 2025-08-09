import 'package:flutter/material.dart';
import '../services/admin_auth_service.dart';

class AdminRouteGuard extends StatefulWidget {
  final Widget child;

  const AdminRouteGuard({Key? key, required this.child}) : super(key: key);

  @override
  _AdminRouteGuardState createState() => _AdminRouteGuardState();
}

class _AdminRouteGuardState extends State<AdminRouteGuard> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    bool isLoggedIn = await AdminAuthService.isAdminLoggedIn();

    if (mounted) {
      setState(() {
        _isAuthenticated = isLoggedIn;
        _isLoading = false;
      });

      // If not authenticated, redirect to login
      if (!isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/admin-login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF1565C0),
              ),
              SizedBox(height: 16),
              Text(
                'Checking admin access...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated ? widget.child : Container();
  }
}
