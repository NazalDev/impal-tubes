import 'package:flutter/material.dart';
import 'package:volync/features/event/presentation/pages/home.dart';
import 'package:volync/features/history/presentation/pages/history.dart';

import 'package:volync/screen/calendar.dart';
import 'package:volync/features/event/presentation/pages/post_event.dart';
import 'package:volync/features/profile/presentation/pages/profile.dart';

class NavigationBarCustom extends StatefulWidget {
  const NavigationBarCustom({super.key});

  @override
  State<NavigationBarCustom> createState() => _NavigationBarCustomState();
}

class _NavigationBarCustomState extends State<NavigationBarCustom> {
  //Key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Navbar
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    HistoryScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,

        selectedIndex: _selectedIndex > 1 ? _selectedIndex + 1 : _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 2) return;
          setState(() {
            _selectedIndex = index > 2 ? index - 1 : index;
          });
        },

        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Kalender',
          ),

          NavigationDestination(
            icon: Icon(Icons.add, color: Colors.transparent),
            label: '',
            enabled: false,
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Riwayat',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),

      floatingActionButton: _selectedIndex == 0
          ? SizedBox(
              width: 72,
              height: 72,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostEventPage()),
                  );
                },
                backgroundColor: Color.fromARGB(255, 85, 169, 210),
                shape: CircleBorder(),
                tooltip: 'Post Event/Forum',
                child: Icon(Icons.add, color: Colors.white, size: 32),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: _pages[_selectedIndex],
    );
  }
}
