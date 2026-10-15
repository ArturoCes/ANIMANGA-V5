import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/cart_cubit.dart';
import '../catalog/manga_detail_page.dart';
import '../widgets/common.dart';
import 'checkout_sheet.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) showMessage(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final cubit = context.read<CartCubit>();
          if (state.loading && state.items.isEmpty) return const Center(child: CircularProgressIndicator());
          if (state.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _run(context, cubit.load),
              child: ListView(children: const [
                SizedBox(height: 80),
                EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Tu carrito está vacío',
                  message: 'Añade volúmenes desde la ficha de cada manga.',
                ),
              ]),
            );
          }
          return ContentWidth(
            maxWidth: 760,
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _run(context, cubit.load),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _CartTile(
                        item: state.items[i],
                        busy: state.busyVolumen == state.items[i].volumen.id,
                        onAdd: () => _run(context, () => cubit.add(state.items[i].volumen)),
                        onRemove: () => _run(context, () => cubit.removeOne(state.items[i].volumen)),
                        onDelete: () => _run(context, () => cubit.removeAll(state.items[i])),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Total (${state.count} artículos)', style: theme.textTheme.titleMedium),
                            const Spacer(),
                            Text(formatPrice(state.total),
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.lock_outline),
                            label: const Text('Finalizar compra'),
                            onPressed: () => showCheckout(context),
                          ),
                        ),
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

class _CartTile extends StatelessWidget {
  const _CartTile({
    required this.item,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  final CartItem item;
  final bool busy;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = item.volumen;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: v.idManga.isEmpty ? null : () => openMangaDetail(context, v.idManga),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CoverImage(v.posterPath, width: 60, height: 88, radius: 8),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.nombre, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text('${formatPrice(v.precio)} / ud.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QtyButton(icon: Icons.remove, onPressed: busy ? null : onRemove, tooltip: 'Quitar uno'),
                        SizedBox(
                          width: 36,
                          child: busy
                              ? const Center(
                                  child:
                                      SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                              : Text('${item.quantity}',
                                  textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          tooltip: 'Añadir uno',
                          onPressed: busy || item.quantity >= v.cantidad ? null : onAdd,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                      tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline), onPressed: busy ? null : onDelete),
                  Text(formatPrice(item.subtotal),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed, required this.tooltip});
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        onPressed: onPressed,
        icon: Icon(icon),
      );
}
