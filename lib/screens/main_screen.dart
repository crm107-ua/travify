import 'package:flutter/material.dart';
import 'package:travify/constants/colors.dart';
import 'package:travify/screens/forms/create_travel.dart';
import 'home_content.dart';
import 'settings_content.dart';
import 'data_content.dart';
import 'search_content.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Las 4 pantallas (IndexedStack)
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
      MaterialPageRoute(builder: (context) => CreateTravelWizard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // 1. Colores principales según tema claro / oscuro
    final Color backgroundColor =
        (brightness == Brightness.dark) ? Colors.black : Colors.white;

    // 2. Colores para íconos activos/inactivos
    final Color activeColor =
        (brightness == Brightness.dark) ? Colors.white : Colors.black;
    final Color inactiveColor =
        (brightness == Brightness.dark) ? Colors.grey[600]! : Colors.grey;

    return Scaffold(
      // Color de fondo principal
      backgroundColor: backgroundColor,

      // Cuerpo que muestra una de las 4 pantallas según _currentIndex
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Botón flotante centrado y desplazado hacia abajo
      floatingActionButton: Transform.translate(
        offset: Offset(0, 40),
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: _onFabPressed,
            backgroundColor:
                AppColors.primary, // Cambia este color al que prefieras
            elevation: 10.0,
            shape: CircleBorder(),
            child: Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      // Barra inferior con muesca para el FAB
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 0,
        // Aquí definimos el color de la barra según el tema
        color: backgroundColor,
        child: Container(
          height: 60,
          // También con el color del tema
          color: backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Botón 1 (Home)
              IconButton(
                icon: Icon(
                  Icons.home,
                  size: 27,
                  color: _currentIndex == 0 ? activeColor : inactiveColor,
                ),
                onPressed: () => _onItemTapped(0),
              ),
              // Botón 2 (Search)
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 27,
                  color: _currentIndex == 1 ? activeColor : inactiveColor,
                ),
                onPressed: () => _onItemTapped(1),
              ),
              SizedBox(width: 50),
              // Botón 3 (Bar Chart)
              IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  size: 27,
                  color: _currentIndex == 2 ? activeColor : inactiveColor,
                ),
                onPressed: () => _onItemTapped(2),
              ),
              // Botón 4 (Settings)
              IconButton(
                icon: Icon(
                  Icons.settings,
                  size: 27,
                  color: _currentIndex == 3 ? activeColor : inactiveColor,
                ),
                onPressed: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
