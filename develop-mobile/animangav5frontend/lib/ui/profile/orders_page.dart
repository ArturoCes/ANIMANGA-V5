import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../widgets/common.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Purchase>> _future = context.read<ShopRepository>().myPurchases();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("d MMM y, HH:mm", 'es_ES');

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
              onAction: () => setState(() => _future = context.read<ShopRepository>().myPurchases()),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final purchases = snapshot.data!;
          if (purchases.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long,
              title: 'Todavía no has comprado nada',
              message: 'Tus pedidos aparecerán aquí.',
            );
          }
          final spent = purchases.fold<double>(0, (s, p) => s + p.total);
          return ContentWidth(
            maxWidth: 760,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text('${purchases.length} compras · ${formatPrice(spent)} en total',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 12),
                for (final p in purchases)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CoverImage(p.posterPath, width: 52, height: 76, radius: 8),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nombreVolumen,
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                Text(dateFormat.format(p.date.toLocal()), style: theme.textTheme.bodySmall),
                                Text('${p.quantity} × ${formatPrice(p.precio)} · ${p.card}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                              ],
                            ),
                          ),
                          Text(formatPrice(p.total),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
