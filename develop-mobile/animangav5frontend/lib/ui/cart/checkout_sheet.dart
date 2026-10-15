import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../state/cart_cubit.dart';
import '../widgets/common.dart';

/// Pasarela de pago simulada: valida la tarjeta (algoritmo de Luhn) y confirma el pedido.
Future<void> showCheckout(BuildContext context) async {
  final paid = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => BlocProvider.value(value: context.read<CartCubit>(), child: const _CheckoutSheet()),
  );
  if (paid == true && context.mounted) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('¡Pedido confirmado!'),
        content: const Text('Puedes consultar tus compras en Perfil › Mis pedidos.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Genial'))],
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet();

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _card = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  bool _paying = false;

  @override
  void dispose() {
    _card.dispose();
    _expiry.dispose();
    _cvc.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _paying = true);
    try {
      await context.read<CartCubit>().checkout(_card.text.replaceAll(' ', ''));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = context.select((CartCubit c) => c.state.total);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pago con tarjeta', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Pasarela de demostración: no se realiza ningún cargo real.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _card,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.creditCardNumber],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()],
              decoration: InputDecoration(
                labelText: 'Número de tarjeta',
                prefixIcon: const Icon(Icons.credit_card),
                helperText: 'Prueba con 4242 4242 4242 4242',
                suffixIcon: IconButton(
                  tooltip: 'Usar tarjeta de prueba',
                  icon: const Icon(Icons.auto_fix_high),
                  onPressed: () {
                    _card.text = '4242 4242 4242 4242';
                    _expiry.text = '12/30';
                    _cvc.text = '123';
                  },
                ),
              ),
              validator: (v) => isValidCard(v ?? '') ? null : 'Número de tarjeta no válido',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiry,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()],
                    decoration: const InputDecoration(labelText: 'Caducidad', hintText: 'MM/AA'),
                    validator: (v) => _validExpiry(v ?? '') ? null : 'Fecha no válida',
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
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _paying ? null : _pay,
              child: _paying
                  ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : Text('Pagar ${formatPrice(total)}'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validExpiry(String value) {
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value);
    if (match == null) return false;
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return false;
    final now = DateTime.now();
    return DateTime(year, month + 1).isAfter(DateTime(now.year, now.month));
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
