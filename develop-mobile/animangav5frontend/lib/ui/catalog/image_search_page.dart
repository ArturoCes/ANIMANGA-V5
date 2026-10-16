import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../widgets/common.dart';
import 'manga_detail_page.dart';

/// Botón de cámara para los buscadores: abre la búsqueda por foto o portada.
class ImageSearchButton extends StatelessWidget {
  const ImageSearchButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Buscar con una foto de la portada',
        icon: const Icon(Icons.photo_camera_outlined),
        onPressed: () => startImageSearch(context),
      );
}

/// Pide la imagen (cámara o galería) y abre los resultados.
Future<void> startImageSearch(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text('Buscar por portada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Haz una foto a un tomo o usa una captura y te decimos qué manga es.',
                  style: TextStyle(color: Theme.of(context).colorScheme.outline)),
            ),
            // En el navegador la cámara solo existe en móviles; en escritorio se elige un fichero
            if (!kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Hacer una foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(kIsWeb ? 'Elegir una imagen' : 'Elegir de la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    ),
  );
  if (source == null || !context.mounted) return;
  final picked = await ImagePicker().pickImage(source: source, maxWidth: 1200, imageQuality: 85);
  if (picked == null || !context.mounted) return;
  final bytes = await picked.readAsBytes();
  if (!context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ImageSearchPage(image: UploadFile(bytes: bytes, filename: picked.name), preview: bytes),
  ));
}

class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({super.key, required this.image, required this.preview});
  final UploadFile image;
  final Uint8List preview;

  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  ImageSearchResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() {
      _error = null;
      _result = null;
    });
    try {
      final result = await context.read<CatalogRepository>().searchByImage(widget.image);
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _retry() {
    Navigator.of(context).pop();
    startImageSearch(context);
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar por portada')),
      body: ContentWidth(
        maxWidth: 640,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _PhotoHeader(preview: widget.preview, searching: result == null && _error == null),
            const SizedBox(height: 24),
            if (_error != null)
              EmptyState(icon: Icons.error_outline, title: 'No se ha podido buscar', message: _error,
                  action: 'Reintentar', onAction: _search)
            else if (result != null) ..._results(result),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(ImageSearchResult result) {
    final theme = Theme.of(context);
    final others = result.found ? result.matches.skip(1).toList() : result.matches;
    return [
      if (result.found)
        _BestMatch(match: result.matches.first)
      else
        EmptyState(
          icon: Icons.image_search,
          title: 'No encontramos este manga en la tienda',
          message: others.isEmpty
              ? 'Prueba con una foto más cercana y recta de la portada, con buena luz.'
              : 'No hay una coincidencia clara, pero quizá sea alguno de estos.',
          action: 'Probar con otra foto',
          onAction: _retry,
        ),
      if (others.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text(result.found ? 'También se parece a' : 'Parecidos',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final m in others) _MatchTile(match: m),
      ],
      if (result.found) ...[
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Buscar con otra foto'),
          ),
        ),
      ],
    ];
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.preview, required this.searching});
  final Uint8List preview;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(preview, width: 84, height: 120, fit: BoxFit.cover, gaplessPlayback: true),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: searching
              ? Row(children: [
                  const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
                  const SizedBox(width: 12),
                  Flexible(child: Text('Comparando con las portadas del catálogo…', style: theme.textTheme.bodyLarge)),
                ])
              : Text('Tu imagen', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
        ),
      ],
    );
  }
}

class _BestMatch extends StatelessWidget {
  const _BestMatch({required this.match});
  final ImageMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = match.manga;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openMangaDetail(context, m.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverImage(match.cover ?? m.coverImage, width: 110, height: 160),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 6),
                      Text('¡Lo tenemos!',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 8),
                    Text(m.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    if (match.volumeNumber != null)
                      Text('Tomo ${match.volumeNumber}', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(m.author, style: TextStyle(color: theme.colorScheme.outline)),
                    const SizedBox(height: 8),
                    if (m.minPrice != null)
                      Text('Desde ${formatPrice(m.minPrice!)}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => openMangaDetail(context, m.id),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Ver ficha'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match});
  final ImageMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CoverImage(match.cover ?? match.manga.coverImage, width: 40, height: 58, radius: 6),
        title: Text(match.manga.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(match.volumeNumber != null ? 'Tomo ${match.volumeNumber}' : match.manga.author),
        trailing: Text('${match.similarity} %', style: TextStyle(color: theme.colorScheme.outline)),
        onTap: () => openMangaDetail(context, match.manga.id),
      ),
    );
  }
}
