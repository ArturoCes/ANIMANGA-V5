import 'dart:convert';
import 'dart:ui';

import 'package:animangav4frontend/blocs/mangas/mangas_bloc.dart';
import 'package:animangav4frontend/models/category.dart';
import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/rest/rest_client.dart';
import 'package:animangav4frontend/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/styles.dart';

class MangasPage extends StatefulWidget {
  const MangasPage({Key? key}) : super(key: key);

  @override
  _MangasPageState createState() => _MangasPageState();
}

class _MangasPageState extends State<MangasPage> {
  late MangaService mangaService;
  late MangasBloc _mangasbloc;
  late MangasBloc _mangasShonen;
  late MangasBloc _mangasSeinen;
  final box = GetStorage();

  @override
  void initState() {
    mangaService = GetIt.instance<MangaService>();
    _mangasbloc = MangasBloc(mangaService)..add(FindAllMangas(10));
    _mangasShonen = MangasBloc(mangaService)..add(FindAllMangasByCat('Shonen'));
    _mangasSeinen = MangasBloc(mangaService)..add(FindAllMangasByCat('Seinen'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => _mangasbloc)],
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 249, 249, 249),
        appBar: AppBar(
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Color.fromARGB(255, 134, 12, 123),
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(box.read('image')),
                ),
              ),
              SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text(
                  box.read('username'),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
                child: Icon(Icons.search),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: _createBody(context),
          ),
        ),
      ),
    );
  }

  Widget _createBody(BuildContext context) {
    return Center(
        child: Column(children: [
      BlocBuilder<MangasBloc, MangasState>(
        bloc: _mangasbloc,
        builder: (context, state) {
          if (state is MangasInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FindAllMangasError) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is FindAllMangasSuccess) {
            return _mangasList(
              context,
              state.mangas,
              state.pagesize,
            );
          } else {
            return const Text('Error al cargar la lista');
          }
        },
      ),
      BlocBuilder<MangasBloc, MangasState>(
        bloc: _mangasSeinen,
        builder: (context, state) {
          if (state is MangasInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FindAllMangasError) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is FindAllMangasSuccess) {
            return _mangasRow(context, state.mangas, state.pagesize, "Seinen");
          } else {
            return const Text('Error al cargar la lista');
          }
        },
      ),
      BlocBuilder<MangasBloc, MangasState>(
        bloc: _mangasShonen,
        builder: (context, state) {
          if (state is MangasInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FindAllMangasError) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is FindAllMangasSuccess) {
            return _mangasRow(context, state.mangas, state.pagesize, "Shonen");
          } else {
            return const Text('Error al cargar la lista');
          }
        },
      ),
    ]));
  }

  Widget _mangasList(
    BuildContext context,
    List<Manga> mangas,
    int pagesize,
  ) {
    return SingleChildScrollView(
      child: _featuredMangas(
        context,
        mangas,
      ),
    );
  }

  Widget _featuredMangas(BuildContext context, List<Manga> mangas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 20),
          child: Text(
            "Mangas destacados",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: mangas.map((manga) => _featuredMangaItem(manga)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _featuredMangaItem(Manga manga) {
    return GestureDetector(
      onTap: () {
        box.write("idManga", manga.id);
        Navigator.pushNamed(context, "/detail");
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 82, 1, 68),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                ApiConstants.imageBaseUrl + manga.posterPath,
                width: MediaQuery.of(context).size.width / 1.5,
                height: MediaQuery.of(context).size.width / 1.2,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 5,
              bottom: 5,
              child: Text(
                utf8.decode(manga.name.codeUnits),
                style: AnimangaStyle.textCustom(
                  Color.fromARGB(255, 255, 255, 255),
                  AnimangaStyle.textSizeFour,
                ),
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mangasRow(
    BuildContext context,
    List<Manga> mangas,
    int pagesize,
    String category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 20),
          child: Text(
            category,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.width / 1.6,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mangas.length,
            itemBuilder: (context, index) {
              if (index == mangas.length - 1 && mangas.length < pagesize) {
                context.watch<MangasBloc>()..add(FindAllMangas(pagesize));
              }
              return _mangaItem(context, mangas[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _mangaItem(BuildContext context, Manga manga) {
    return GestureDetector(
      onTap: () {
        box.write("idManga", manga.id);
        Navigator.pushNamed(context, "/detail");
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 82, 1, 68),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                ApiConstants.imageBaseUrl + manga.posterPath,
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.width / 1.6,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 5,
              bottom: 5,
              child: Text(
                utf8.decode(manga.name.codeUnits),
                style: AnimangaStyle.textCustom(
                  Color.fromARGB(255, 255, 255, 255),
                  AnimangaStyle.textSizeFour,
                ),
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mangasbloc.close();
    super.dispose();
  }
}
