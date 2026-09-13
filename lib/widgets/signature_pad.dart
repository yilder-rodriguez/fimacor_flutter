import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Controla un [SignaturePad]: guarda los trazos, permite borrarlos y
/// exportar el dibujo como PNG en base64 (formato "data:image/png;base64,..."
/// que exige el servidor, igual que la firma manuscrita del navegador web).
class SignaturePadController extends ChangeNotifier {
  final GlobalKey repaintKey = GlobalKey();
  final List<Offset?> _points = [];

  List<Offset?> get points => List.unmodifiable(_points);

  bool get isEmpty => !_points.any((p) => p != null);

  void addPoint(Offset point) {
    _points.add(point);
    notifyListeners();
  }

  void endStroke() {
    _points.add(null);
    notifyListeners();
  }

  void clear() {
    _points.clear();
    notifyListeners();
  }

  Future<String?> exportPngBase64() async {
    if (isEmpty) return null;
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final bytes = byteData.buffer.asUint8List();
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }
}

/// Lienzo donde Subdireccion dibuja su firma con el dedo. El fondo es
/// blanco solido (no transparente) para que el acta se vea bien impresa.
class SignaturePad extends StatefulWidget {
  const SignaturePad({required this.controller, super.key});

  final SignaturePadController controller;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: RepaintBoundary(
        key: widget.controller.repaintKey,
        child: Container(
          color: Colors.white,
          height: 180,
          width: double.infinity,
          child: GestureDetector(
            onPanStart: (details) =>
                widget.controller.addPoint(details.localPosition),
            onPanUpdate: (details) =>
                widget.controller.addPoint(details.localPosition),
            onPanEnd: (_) => widget.controller.endStroke(),
            child: CustomPaint(
              painter: _SignaturePainter(widget.controller.points),
              child: widget.controller.isEmpty
                  ? const Center(
                      child: Text(
                        'Firma aqui con el dedo',
                        style: TextStyle(color: Color(0xFFB9C2BE)),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF16352D)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a != null && b != null) {
        canvas.drawLine(a, b, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
