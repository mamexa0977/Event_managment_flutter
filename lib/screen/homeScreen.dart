import 'package:event_mng_sys/provider.dart';
import 'package:event_mng_sys/screen/navigation/profile/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/screen/navigation/events/event_create.dart';
import 'package:event_mng_sys/screen/navigation/events/event_list/event_list.dart';
import 'package:event_mng_sys/screen/navigation/events/myevent.dart';
import 'package:event_mng_sys/screen/navigation/profile/userProfile.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  bool _isLoading = true;

  Future<void> _checkUser() async {
    await Provider.of<UserProvider>(context, listen: false).fetchUser();
    setState(() {
      _isLoading = false;
    });
  }

  int _selectedIndex = 0;

  // Screens for navigation
  final List<Widget> _screens = [
    const EventList(),
    const Myevent(),
    const EventCreate(),
    const ProfileScreen(),
  ];

  // Titles for each tab (optional for AppBar)
  final List<String> _titles = [
    "Home",
    "Registered Event",
    "Event create",
    "Profile",
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      // appBar: AppBar(title: Text(_titles[_selectedIndex]), centerTitle: true),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color(0xFF6759FF), // Active icon/text color
        unselectedItemColor: Colors.grey, // Inactive icon/text color
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Events'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
