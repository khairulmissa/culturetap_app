// lib/screens/home_main.dart
import 'package:flutter/material.dart';
import 'package:culturetap_app/models/user.dart';
import 'package:culturetap_app/screens/state_selection_screen.dart'; 

class HomeMain extends StatelessWidget {
  final User? currentUser; 
  
  const HomeMain({super.key, this.currentUser}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CultureTap'),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFE0F2F1)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flag, color: Colors.red, size: 26),
                      const SizedBox(width: 8),
                      const Text(
                        'Welcome to Malaysia!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Discover authentic cultural experiences',
                          style: TextStyle(fontSize: 13), 
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4), 
                        const Text(
                          'and hidden gems across beautiful',
                          style: TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Malaysia with CultureTap',
                          style: TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8), 
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10), 
                        const Text(
                          'Hope you enjoy your time here',
                          style: TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF00796B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Column(
                    children: [
                      // Book your activity button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/booking');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00796B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Explore Malaysia button 
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentUser != null) {
                              Navigator.pushNamed(
                                context, 
                                '/select-state',
                                arguments: currentUser,
                              );
                            } else {
                              Navigator.pushNamed(context, '/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF00796B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFF00796B), width: 2),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'MAP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  const Text(
                    'CultureTap © 2024',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
      
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.teal,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0: // Home
                break;
              case 1: // Booking
                Navigator.pushNamed(context, '/booking');
                break;
              case 2: // Map/Explore Malaysia 
                if (currentUser != null) {
                  Navigator.pushNamed(
                    context, 
                    '/select-state',
                    arguments: currentUser,
                  );
                } else {
                  Navigator.pushNamed(context, '/login');
                }
                break;
              case 3: // Profile
                if (currentUser != null) {
                  Navigator.pushNamed(
                    context, 
                    '/profile',
                    arguments: currentUser,
                  );
                } else {
                  Navigator.pushNamed(context, '/login');
                }
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 22),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 22),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map, size: 22),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}