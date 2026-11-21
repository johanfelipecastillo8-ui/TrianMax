import 'package:material_ui/material_ui.dart';
import '../core/responsive.dart';
import '../core/theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.isMobile(context) ? 22 : 34),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.softLine))),
      child: Column(children: [
        ShaderMask(
          shaderCallback: (r) => T.goldGradient.createShader(r),
          child: const Text('TRIAN MAX', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 4, color: Colors.white, fontSize: 14)),
        ),
        const SizedBox(height: 8),
        const Text('Catálogo 2026 · Todo lo que buscas, en un solo lugar', textAlign: TextAlign.center, maxLines: 2, style: TextStyle(color: T.muted, fontSize: 11.5)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/admin'),
          child: const Text('Acceso dueño', style: TextStyle(color: T.goldDark, fontSize: 11, decoration: TextDecoration.underline)),
        ),
      ]),
    );
  }
}
