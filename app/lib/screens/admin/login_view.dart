import 'dart:html' as html;
import 'package:material_ui/material_ui.dart';
import '../../core/theme.dart';
import '../../data/services/api_service.dart';

class AdminLogin extends StatefulWidget {
  final VoidCallback onSuccess;
  const AdminLogin({super.key, required this.onSuccess});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final ctrl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _submit() async {
    setState(() { loading = true; error = null; });
    try {
      final token = await Api.login(ctrl.text.trim());
      Api.token = token;
      html.window.localStorage['tm_token'] = token;
      widget.onSuccess();
    } on ApiException catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.6), radius: 1.2, colors: [Color(0x22D4AF37), T.bg])),
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/logo-trianmax.jpg', width: 74, height: 74)),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (r) => T.goldGradient.createShader(r),
              child: Text('TRIAN MAX', style: T.serif.copyWith(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(height: 6),
            const Text('Panel del dueño', style: TextStyle(color: T.muted)),
            const SizedBox(height: 28),
            TextField(
              controller: ctrl,
              obscureText: true,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(color: T.text),
              decoration: const InputDecoration(hintText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline, color: T.muted)),
            ),
            if (error != null)
              Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: T.danger, fontSize: 13))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity, height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: T.goldGradient, borderRadius: BorderRadius.circular(99)),
                child: MaterialButton(
                  onPressed: loading ? null : _submit,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF151005)))
                      : const Text('Ingresar', style: TextStyle(color: Color(0xFF151005), fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ),
          ]),
        ),
      )),
    );
  }
}
