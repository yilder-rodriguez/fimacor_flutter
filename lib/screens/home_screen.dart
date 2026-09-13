import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'machines_screen.dart';
import 'maintenance_screen.dart';
import 'manuals_screen.dart';
import 'relocation_screen.dart';

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
    // Solo el Cuentadante solicita reubicaciones (igual que en la web:
    // Reubicacion_maquina.jsp solo aparece para ese rol); el Tecnico no
    // ve esta pestana.
    final mostrarReubicacion = widget.api.isCuentadante;

    final pages = [
      DashboardScreen(
        api: widget.api,
        onOpenMachines: () => setState(() => _index = 1),
      ),
      MachinesScreen(api: widget.api),
      MaintenanceScreen(api: widget.api),
      if (mostrarReubicacion) RelocationScreen(api: widget.api),
      ManualsScreen(api: widget.api),
    ];

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.space_dashboard_outlined),
        selectedIcon: Icon(Icons.space_dashboard_rounded),
        label: 'Inicio',
      ),
      const NavigationDestination(
        icon: Icon(Icons.precision_manufacturing_outlined),
        selectedIcon: Icon(Icons.precision_manufacturing_rounded),
        label: 'Maquinas',
      ),
      const NavigationDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build_rounded),
        label: 'Mantenimiento',
      ),
      if (mostrarReubicacion)
        const NavigationDestination(
          icon: Icon(Icons.move_up_outlined),
          selectedIcon: Icon(Icons.move_up_rounded),
          label: 'Reubicar',
        ),
      const NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book_rounded),
        label: 'Manuales',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('FIMACOR'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                widget.api.role ?? '',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
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
        destinations: destinations,
      ),
    );
  }
}
