const shipLabels = {
  'recojo': 'Recojo en tienda',
  'delivery': 'Delivery',
  'nacional': 'Envío nacional',
};

const orderStatuses = ['nuevo', 'confirmado', 'entregado', 'cancelado'];

String fmt(num n) =>
    '\$ ${n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';

String fmtDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}
