import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../widgets/common.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<PageResult<Order>> _future = context.read<ShopRepository>().myOrders();

  void _reload() => setState(() => _future = context.read<ShopRepository>().myOrders());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM y', 'es_ES');

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'No se pudieron cargar tus pedidos',
              message: snapshot.error.toString(),
              action: 'Reintentar',
              onAction: _reload,
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!.content;
          if (orders.isEmpty) {
            return const EmptyState(
                icon: Icons.receipt_long,
                title: 'Todavía no has hecho ningún pedido',
                message: 'Tus pedidos aparecerán aquí.');
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ContentWidth(
              maxWidth: 760,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final o = orders[i];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        await Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: o.id)));
                        _reload();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          SizedBox(
                            width: 70,
                            height: 76,
                            child: Stack(children: [
                              for (var j = 0; j < o.items.length.clamp(0, 3); j++)
                                Positioned(
                                  left: j * 10.0,
                                  child: CoverImage(o.items[j].coverImage, width: 48, height: 72, radius: 6),
                                ),
                            ]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.number,
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                Text('${dateFormat.format(o.createdAt.toLocal())} · ${o.totalUnits} uds.',
                                    style: theme.textTheme.bodySmall),
                                const SizedBox(height: 6),
                                OrderStatusBadge(o.status),
                              ],
                            ),
                          ),
                          Text(formatPrice(o.total),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const Icon(Icons.chevron_right),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
