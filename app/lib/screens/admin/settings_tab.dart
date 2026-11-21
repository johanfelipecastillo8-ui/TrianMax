import 'package:material_ui/material_ui.dart';
import '../../core/theme.dart';
import '../../data/services/api_service.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});
  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  final ctrl = TextEditingController();
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final wa = await Api.getWhatsApp();
    if (mounted) setState(() { ctrl.text = wa; loading = false; });
  }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      final wa = await Api.saveWhatsApp(ctrl.text.trim());
      if (mounted) {
        setState(() { ctrl.text = wa; saving = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Número de WhatsApp actualizado')));
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: T.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: T.gold));
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Número de WhatsApp de la tienda', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      const SizedBox(height: 6),
      const Text('Código de país + número, sin "+" (ej. 51987654321). Los pedidos del catálogo llegarán a este número.', style: TextStyle(color: T.muted, fontSize: 12.5)),
      const SizedBox(height: 14),
      TextField(controller: ctrl, keyboardType: TextInputType.phone, style: const TextStyle(color: T.text), decoration: const InputDecoration(hintText: '51987654321', prefixIcon: Icon(Icons.chat_bubble_outline, color: T.muted))),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 44,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: T.softGradient, borderRadius: BorderRadius.circular(99)),
            child: MaterialButton(
              onPressed: saving ? null : _save,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              child: saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: T.onAccent))
                  : const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Guardar', style: TextStyle(color: T.onAccent, fontWeight: FontWeight.w800))),
            ),
          ),
        ),
      ),
    ]);
  }
}
