import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'login_screen.dart';
import 'manuals_screen.dart';
import 'subdireccion_machines_screen.dart';
import 'subdireccion_relocations_screen.dart';

/// Panel de inicio del rol Subdireccion. Su funcion propia y unica en el
/// sistema es autorizar (firmar) reubicaciones de maquinas; ademas puede
/// consultar el catalogo completo de maquinas y los manuales, igual que
/// cualquier otro rol con visibilidad global (ver Menu.jsp).
class SubdireccionHomeScreen extends StatefulWidget {
  const SubdireccionHomeScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<SubdireccionHomeScreen> createState() => _SubdireccionHomeScreenState();
}

class _SubdireccionHomeScreenState extends State<SubdireccionHomeScreen> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      SubdireccionRelocationsScreen(api: widget.api),
      SubdireccionMachinesScreen(api: widget.api),
      ManualsScreen(api: widget.api),
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
                widget.api.role ?? 'Subdireccion',
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.move_up_outlined),
            selectedIcon: Icon(Icons.move_up_rounded),
            label: 'Reubicaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.precision_manufacturing_outlined),
            selectedIcon: Icon(Icons.precision_manufacturing_rounded),
            label: 'Maquinas',
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
