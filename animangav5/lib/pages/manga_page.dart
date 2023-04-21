import 'package:animangav4frontend/blocs/manga/bloc/manga_bloc.dart';
import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/pages/error_page.dart';
import 'package:animangav4frontend/rest/rest.dart';
import 'package:animangav4frontend/services/mangas_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

class MangaPage extends StatefulWidget {
  const MangaPage({Key? key}) : super(key: key);

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  late MangasService mangasService;
  late MangaBloc _mangaBloc;
  final box = GetStorage();

  @override
  void initState() {
    mangasService = GetIt.instance<MangaService>();
    _mangaBloc = MangaBloc(mangasService)..add(FetchManga());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => _mangaBloc),
        ],
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 249, 249, 249),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 134, 12, 123),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text('Producto'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {},
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: _createBody(context),
            ),
          ),
        ));
  }

  Widget _createBody(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          BlocBuilder<MangaBloc, MangaState>(
            bloc: _mangaBloc,
            builder: (context, state) {
              if (state is MangaInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MangaFetchError) {
                return ErrorPage(
                  message: state.message,
                  retry: () {
                    context.watch<MangaBloc>().add(const FetchManga());
                  },
                );
              } else if (state is MangaFetched) {
                return buildOne(context, state.manga);
              } else {
                return const Text('No se pudo cargar el manga');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildOne(BuildContext context, Manga manga) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 390,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  ApiConstants.imageBaseUrl + manga.posterPath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              manga.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              manga.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Autor: ' + manga.author,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fecha de publicación: ' + manga.releaseDate,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
