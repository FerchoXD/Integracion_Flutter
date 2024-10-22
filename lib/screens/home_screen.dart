import 'package:flutter/material.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/screens/chat_history_screen.dart';
import 'package:flutter_gemini/screens/chat_screen.dart';
import 'package:flutter_gemini/screens/location_screen.dart';
import 'package:flutter_gemini/screens/profile_screen.dart';
import 'package:flutter_gemini/screens/qr_code_screen.dart';
import 'package:flutter_gemini/screens/sensors_plus_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // list of screens
  final List<Widget> _screens = [
    const ProfileScreen(),
    const ChatScreen(),
    const ChatHistoryScreen(),
    QrCodeScreen(),
    LocationScreen(),
    SensorsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
            body: PageView(
              controller: chatProvider.pageController,
              children: _screens,
              onPageChanged: (index) {
                chatProvider.setCurrentIndex(newIndex: index);
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: chatProvider.currentIndex,
              elevation: 0,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                chatProvider.setCurrentIndex(newIndex: index);
                chatProvider.pageController.jumpToPage(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_outlined),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  label: 'Historial',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code),
                  label: 'QR',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on_outlined),
                  label: 'Ubicación',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sensor_window_outlined),
                  label: 'Sensores',
                ),
              ],
            ));
      },
    );
  }
}
