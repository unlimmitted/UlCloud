import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:ultimate_cloud/last_views.dart';
import 'package:ultimate_cloud/search.dart';
import 'package:ultimate_cloud/files.dart';
import 'package:ultimate_cloud/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(
    const MaterialApp(
      home: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Navigation(),
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;
  final GlobalKey<FilesScreenState> _filesScreenKey = GlobalKey<FilesScreenState>();

  @override
  void initState() {
    super.initState();

    _widgetOptions = [
      FilesScreen(key: _filesScreenKey),
      const LastViewsContent(),
      const SearchContainer(),
      const SettingsContainer(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget? _buildFab() {
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        onPressed: () {
          _filesScreenKey.currentState?.uploadFile(); // ← теперь вызывается метод из FilesScreen
        },
        child: const Icon(Icons.cloud_upload),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_drive_file_sharp),
            label: 'My files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Last views',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }
}
