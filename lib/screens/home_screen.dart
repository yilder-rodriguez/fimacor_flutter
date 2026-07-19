import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'machines_screen.dart';
import 'maintenance_screen.dart';
import 'manuals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        api: widget.api,
        onOpenMachines: () => setState(() => _index = 1),
      ),
      MachinesScreen(api: widget.api),
      MaintenanceScreen(api: widget.api),
      ManualsScreen(api: widget.api),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FIMACOR'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () async {
              await widget.api.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.precision_manufacturing_outlined),
            selectedIcon: Icon(Icons.precision_manufacturing_rounded),
            label: 'Maquinas',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Mantenimiento',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Manuales',
          ),
        ],
      ),
    );
  }
}
