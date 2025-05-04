import 'package:flutter/material.dart';
import 'package:travify/screens/forms/form_travel.dart';
import 'home_content.dart';
import 'settings_content.dart';
import 'data_content.dart';
import 'search_content.dart';

class MainScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 3;

  final List<Widget> _screens = [
    HomeContent(),
    SearchContent(),
    DataContent(),
    SettingsContent(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFabPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateOrEditTravelWizard()),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        height: 60, // igual a la altura del BottomAppBar
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 27,
              color: _currentIndex == index ? activeColor : inactiveColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final Color backgroundColor =
        (brightness == Brightness.dark) ? Colors.black : Colors.white;
    final Color activeColor =
        (brightness == Brightness.dark) ? Colors.white : Colors.black;
    final Color inactiveColor =
        (brightness == Brightness.dark) ? Colors.grey[600]! : Colors.grey;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 8,
            color: backgroundColor,
            child: Container(
              height: 60,
              color: backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(
                      icon: Icons.home,
                      index: 0,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor),
                  _buildNavItem(
                      icon: Icons.search,
                      index: 1,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor),
                  SizedBox(width: 50), // espacio para FAB
                  _buildNavItem(
                      icon: Icons.bar_chart,
                      index: 2,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor),
                  _buildNavItem(
                      icon: Icons.settings,
                      index: 3,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom:
              53, // 20 + altura del BottomAppBar (60) = 80 (efecto de bajar a 40)
          left:
              MediaQuery.of(context).size.width / 2 - 30, // 70 / 2 para centrar
          child: GestureDetector(
            onTap: _onFabPressed,
            child: Container(
              width: 60,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white,
                    Color.fromARGB(255, 97, 96, 96),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
