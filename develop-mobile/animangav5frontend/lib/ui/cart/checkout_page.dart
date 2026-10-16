import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/auth_cubit.dart';
import '../../state/cart_cubit.dart';
import '../profile/order_detail_page.dart';
import '../widgets/common.dart';

/// Pago del carrito: dirección de envío y tarjeta (pasarela simulada, no se cobra nada).
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: context.read<AuthCubit>().user?.fullName);
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postalCode = TextEditingController();
  final _phone = TextEditingController();
  final _card = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  bool _paying = false;

  @override
  void dispose() {
    for (final c in [_name, _address, _city, _postalCode, _phone, _card, _expiry, _cvc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      _address.text = 'Calle Feria 12, 2ºB';
      _city.text = 'Sevilla';
      _postalCode.text = '41003';
      _phone.text = '600 123 123';
      _card.text = '4242 4242 4242 4242';
      _expiry.text = '12/30';
      _cvc.text = '123';
    });
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _paying = true);
    try {
      final order = await context.read<ShopRepository>().checkout(
            shipping: ShippingAddress(
              fullName: _name.text.trim(),
              address: _address.text.trim(),
              city: _city.text.trim(),
              postalCode: _postalCode.text.trim(),
              phone: _phone.text.trim(),
            ),
            cardNumber: _card.text.replaceAll(' ', ''),
            cardExpiry: _expiry.text,
            cardCvc: _cvc.text,
          );
      if (!mounted) return;
      context.read<CartCubit>().cleared();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => OrderConfirmationPage(order: order)));
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        showMessage(context, e.toString(), error: true);
        // El stock puede haber cambiado: se refresca el carrito
        context.read<CartCubit>().load().ignore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.select((CartCubit c) => c.state.cart);
    String? required(String? v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tramitar pedido'),
        actions: [
          IconButton(
            tooltip: 'Rellenar con datos de prueba',
            onPressed: _fillDemo,
            icon: const Icon(Icons.auto_fix_high),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ContentWidth(
          maxWidth: 640,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _Section(title: 'Dirección de envío', icon: Icons.local_shipping_outlined, children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nombre del destinatario'),
                  textCapitalization: TextCapitalization.words,
                  validator: required,
                ),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Dirección', hintText: 'Calle, número, piso'),
                  autofillHints: const [AutofillHints.streetAddressLine1],
                  validator: required,
                ),
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _city,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      validator: required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _postalCode,
                      decoration: const InputDecoration(labelText: 'Código postal'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                      validator: (v) => RegExp(r'^\d{5}$').hasMatch(v ?? '') ? null : '5 dígitos',
                    ),
                  ),
                ]),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      RegExp(r'^\+?[0-9 ]{9,15}$').hasMatch(v?.trim() ?? '') ? null : 'Teléfono no válido',
                ),
              ]),
              _Section(title: 'Pago con tarjeta', icon: Icons.credit_card, children: [
                Text('Pasarela de demostración: no se realiza ningún cargo real.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                TextFormField(
                  controller: _card,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.creditCardNumber],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()],
                  decoration: const InputDecoration(
                      labelText: 'Número de tarjeta', helperText: 'Prueba con 4242 4242 4242 4242'),
                  validator: (v) => isValidCard(v ?? '') ? null : 'Número de tarjeta no válido',
                ),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiry,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()],
                      decoration: const InputDecoration(labelText: 'Caducidad', hintText: 'MM/AA'),
                      validator: (v) => isValidExpiry(v ?? '', DateTime.now()) ? null : 'Fecha no válida',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvc,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                      decoration: const InputDecoration(labelText: 'CVC'),
                      validator: (v) => (v?.length ?? 0) >= 3 ? null : 'CVC no válido',
                    ),
                  ),
                ]),
              ]),
              _Section(title: 'Resumen', icon: Icons.receipt_long_outlined, children: [
                for (final line in cart.items)
                  Row(children: [
                    Expanded(child: Text('${line.quantity} × ${line.volume.title}')),
                    Text(formatPrice(line.subtotal)),
                  ]),
                const Divider(),
                Row(children: [
                  const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))),
                  Text(formatPrice(cart.total),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ]),
              ]),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _paying || cart.items.isEmpty ? null : _pay,
                child: _paying
                    ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text('Pagar ${formatPrice(cart.total)}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
              ],
            ),
          ),
        ),
      );
}

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Color(0x222E7D32),
                  child: Icon(Icons.check_rounded, size: 52, color: AppColors.success),
                ),
                const SizedBox(height: 20),
                Text('¡Pedido confirmado!',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Número de pedido ${order.number}', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Lo enviaremos a ${order.shipping.address}, ${order.shipping.city}. '
                  'Total pagado: ${formatPrice(order.total)}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id))),
                  child: const Text('Ver el pedido'),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Seguir comprando')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Valida el número de tarjeta con el algoritmo de Luhn.
bool isValidCard(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 13 || digits.length > 19) return false;
  var sum = 0;
  var doubleIt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = int.parse(digits[i]);
    if (doubleIt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    doubleIt = !doubleIt;
  }
  return sum % 10 == 0;
}

/// Caducidad MM/AA no vencida respecto a [now].
bool isValidExpiry(String value, DateTime now) {
  final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value);
  if (match == null) return false;
  final month = int.parse(match.group(1)!);
  final year = 2000 + int.parse(match.group(2)!);
  if (month < 1 || month > 12) return false;
  return DateTime(year, month + 1).isAfter(DateTime(now.year, now.month));
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final limited = digits.length > 19 ? digits.substring(0, 19) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final text = digits.length > 2 ? '${digits.substring(0, 2)}/${digits.substring(2)}' : digits;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
