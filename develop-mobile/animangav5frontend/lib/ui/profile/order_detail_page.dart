import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../catalog/manga_detail_page.dart';
import '../widgets/common.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<Order> _future = context.read<ShopRepository>().order(widget.orderId);
  bool _cancelling = false;

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('Se anulará el pedido y no se te cobrará nada. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _cancelling = true);
    try {
      final order = await context.read<ShopRepository>().cancel(widget.orderId);
      if (!mounted) return;
      setState(() {
        _future = Future.value(order);
        _cancelling = false;
      });
      showMessage(context, 'Pedido cancelado');
    } catch (e) {
      if (mounted) {
        setState(() => _cancelling = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pedido')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
                icon: Icons.cloud_off, title: 'No se pudo cargar el pedido', message: snapshot.error.toString());
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final o = snapshot.data!;
          final steps = [OrderStatus.paid, OrderStatus.shipped, OrderStatus.delivered];
          final current = steps.indexOf(o.status);

          return ContentWidth(
            maxWidth: 680,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(o.number, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      Text(DateFormat("d 'de' MMMM 'de' y, HH:mm", 'es_ES').format(o.createdAt.toLocal()),
                          style: TextStyle(color: theme.colorScheme.outline)),
                    ]),
                  ),
                  OrderStatusBadge(o.status),
                ]),
                const SizedBox(height: 20),
                if (o.status != OrderStatus.cancelled)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: Row(children: [
                        for (var i = 0; i < steps.length; i++) ...[
                          Expanded(
                            child: Column(children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: i <= current
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  [Icons.payments_outlined, Icons.local_shipping_outlined, Icons.home_outlined][i],
                                  size: 18,
                                  color: i <= current ? theme.colorScheme.onPrimary : theme.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(steps[i].label, style: theme.textTheme.bodySmall),
                            ]),
                          ),
                        ],
                      ]),
                    ),
                  ),
                const SizedBox(height: 16),
                Card(
                  child: Column(children: [
                    for (final line in o.items)
                      ListTile(
                        onTap: line.mangaId == null ? null : () => openMangaDetail(context, line.mangaId!),
                        leading: CoverImage(line.coverImage, width: 40, height: 58, radius: 6),
                        title: Text(line.volumeTitle),
                        subtitle: Text('${line.quantity} × ${formatPrice(line.unitPrice)}'),
                        trailing: Text(formatPrice(line.subtotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Tarjeta ···· ${o.cardLast4}'),
                      trailing: Text(formatPrice(o.total),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(o.shipping.fullName),
                    subtitle: Text(
                        '${o.shipping.address}\n${o.shipping.postalCode} ${o.shipping.city} · ${o.shipping.phone}'),
                    isThreeLine: true,
                  ),
                ),
                if (o.status == OrderStatus.paid) ...[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _cancelling ? null : _cancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar pedido'),
                    style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 6),
                  Text('Puedes cancelarlo mientras no se haya enviado.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
