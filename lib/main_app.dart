
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hellow/pages/EditProfilePage.dart';
import 'package:hellow/pages/plant_prediction_screen.dart';
import 'package:hellow/pages/splash_screen.dart';
import 'package:hellow/pages/register_page.dart';
import 'package:hellow/pages/home_page.dart';
import 'package:hellow/pages/chat_page.dart';
import 'package:hellow/pages/community_page.dart';
import 'package:hellow/pages/soil_page.dart';
import 'package:hellow/pages/irrigation_page.dart';
import 'package:hellow/pages/login_page.dart';

const kBackgroundColor = Colors.white;
const kOliveColor = Color.fromARGB(255, 44, 82, 40); // زيتوني داكن

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Green Grow',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => const NavigationScreen(),
        '/register': (context) => const RegisterPage(),
        '/edit-profile': (context) => const EditProfilePage(),
      },
    );
  }
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 2;

  final List<IconData> _icons = [
    Icons.people,
    Icons.eco,
    Icons.home,
    Icons.chat,
    Icons.water_drop,
  ];

  final List<Widget> _pages = [
    const CommunityPage(),
    const PlantPredictionScreen(),
    const HomePage(),
    const ChatPage(),
    IrrigationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment(
                -1 + (_selectedIndex * (2 / (_icons.length - 1))),
                0,
              ),
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width / _icons.length,
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 30,
                  width: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 15, 77, 48),
                        Color.fromARGB(255, 5, 14, 8),
                      ],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(4, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 0,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_icons.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      height: 80,
                      alignment: Alignment.bottomCenter,
                      child: index == _selectedIndex
                          ? Container(
                              height: 70,
                              width: 45,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 15, 77, 48),
                                    Color.fromARGB(255, 5, 14, 8),
                                  ],
                                  begin: Alignment.bottomRight,
                                  end: Alignment.topLeft,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _icons[index],
                                color: Colors.white,
                                size: 28,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Icon(
                                _icons[index],
                                color: kOliveColor,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
