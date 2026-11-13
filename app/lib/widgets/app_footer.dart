import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 34),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x10FFFFFF)))),
      child: Column(children: [
        ShaderMask(
          shaderCallback: (r) => T.goldGradient.createShader(r),
          child: const Text('TRIAN MAX', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 4, color: Colors.white, fontSize: 14)),
        ),
        const SizedBox(height: 8),
        const Text('Catálogo 2026 · Todo lo que buscas, en un solo lugar', style: TextStyle(color: T.muted, fontSize: 12)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/admin'),
          child: const Text('Acceso dueño', style: TextStyle(color: Color(0x66D4AF37), fontSize: 11, decoration: TextDecoration.underline)),
        ),
      ]),
    );
  }
}
