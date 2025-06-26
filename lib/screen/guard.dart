import 'package:event_mng_sys/provider.dart';
import 'package:event_mng_sys/screen/auth/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homeScreen.dart';
import 'auth/verifyPage.dart';

class Guard extends StatefulWidget {
  const Guard({super.key});

  @override
  _GuardState createState() => _GuardState();
}

class _GuardState extends State<Guard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  // Fetch user data and store it in the provider
  Future<void> _checkUser() async {
    await Provider.of<UserProvider>(context, listen: false).fetchUser();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).appUser;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const LoginScreen();  // User not logged in
    } else if (user.email == null || !FirebaseAuth.instance.currentUser!.emailVerified) {
      return const Verify();  // User logged in but email not verified
    } else {
      return HomeScreen();  // Pass the AppUser to HomeScreen
    }
  }
}
