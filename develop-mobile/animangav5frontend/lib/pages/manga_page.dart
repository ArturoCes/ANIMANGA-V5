import 'dart:ui';
import 'package:animangav4frontend/blocs/characters/bloc/character_bloc.dart';
import 'package:animangav4frontend/blocs/manga/bloc/manga_bloc.dart';
import 'package:animangav4frontend/blocs/manga_favorite/manga_favorite_bloc.dart';
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
  late MangaService mangaService;
  late MangaBloc _mangaBloc;
  late CharacterBloc _characterBloc;
  final box = GetStorage();
  bool _isCharacters = true;
  bool _isFavorite = false;

  @override
  void initState() {
    mangaService = GetIt.instance<MangaService>();
    _mangaBloc = MangaBloc(mangaService)..add(FetchManga());
    _characterBloc = CharacterBloc(mangaService)
      ..add(FetchCharacters(box.read('idManga')));

    super.initState();
  }

  @override
  void dispose() {
    _mangaBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MangaBloc>.value(value: _mangaBloc),
        BlocProvider(create: (context) => MangaFavoriteBloc(mangaService)),
        
      ],
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 249, 249, 249),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 134, 12, 123),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('Producto'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _mangaBloc.add(FetchManga());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: _createBody(context),
          ),
        ),
      ),
    );
  }

  Widget _createBody(BuildContext context) {
    return BlocBuilder<MangaBloc, MangaState>(
      bloc: _mangaBloc,
      builder: (context, mangaState) {
        if (mangaState is MangaInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (mangaState is MangaFetchError) {
          return ErrorPage(
            message: mangaState.message,
            retry: () {
              context.watch<MangaBloc>().add(const FetchManga());
            },
          );
        } else if (mangaState is MangaFetched) {
          return BlocBuilder<CharacterBloc, CharacterState>(
            bloc: _characterBloc,
            builder: (context, characterState) {
              if (characterState is CharactersIsLoadinng) {
                return const Center(child: CircularProgressIndicator());
              } else if (characterState is CharactersFetched) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildOne(context, mangaState.manga),
                      SizedBox(height: 20),
                      Visibility(
                        visible: _isCharacters,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Personajes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    characterState.characters.numberOfElements,
                                itemBuilder: (context, index) {
                                  final character =
                                      characterState.characters.content[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage('kewkas.jpg'),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          character.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          character.description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !_isCharacters,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Puntuación",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blue,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    mangaState.manga.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('No se pudo cargar los personajes');
              }
            },
          );
        } else {
          return const Text('No se pudo cargar el manga');
        }
      },
    );
  }

  Widget favorite(context) {
    if (box.read("favorite")) {
      return InkWell(
        onTap: () {
          setState(() {
            _isFavorite = box.read("favorite");
          });
             BlocProvider.of<MangaFavoriteBloc>(context)
            .add(const RemoveMangaFavorite());
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(pageBuilder: (_, __, ___) => const MangaPage()),
              );   
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              width: 40, // Ajusta el tamaño del círculo
              height: 40, // Ajusta el tamaño del círculo
            ),
            Icon(
              Icons.favorite,
              color: Colors.purple,
              size: 24, // Ajusta el tamaño del ícono del corazón
            ),
          ],
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          setState(() {
            _isFavorite = box.read("favorite");
          });
          BlocProvider.of<MangaFavoriteBloc>(context)
              .add(const AddMangaFavorite());
           Navigator.pushReplacement(
                context,
                PageRouteBuilder(pageBuilder: (_, __, ___) => const MangaPage()),
              );    
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              width: 40, // Ajusta el tamaño del círculo
              height: 40, // Ajusta el tamaño del círculo
            ),
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: 24, // Ajusta el tamaño del ícono del corazón
            ),
          ],
        ),
      );
    }
  }

  Widget buildOne(BuildContext context, Manga manga) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  ApiConstants.imageBaseUrl + manga.posterPath,
                  width: MediaQuery.of(context).size.width,
                  height: 190,
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 190,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    ApiConstants.imageBaseUrl + manga.posterPath,
                  ),
                  radius: 80,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nombre de la obra: ' + manga.name,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                favorite(context)
              ],
            ),
            Text('Descripción: ' + manga.description,
                style: TextStyle(fontSize: 16)),
            Text('Autor de la obra: ' + manga.author,
                style: TextStyle(fontSize: 16)),
            Text('Fecha de salida: ' + manga.releaseDate,
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: CustomSwitch(
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                value: _isCharacters,
                onChanged: (bool newValue) {
                  setState(() {
                    _isCharacters = newValue;
                  });
                },
              ),
            ),
          ],
        ));
  }
}

class CustomSwitch extends StatelessWidget {
  final Color activeColor;
  final Color inactiveColor;
  final bool value;
  final Function(bool) onChanged;

  CustomSwitch({
    required this.activeColor,
    required this.inactiveColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 145,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: value
                ? [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)]
                : [Color(0xFF525252), Color(0xFF3D3D3D), Color(0xFF313131)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              left: value ? 72.5 : 2.5,
              top: 2.5,
              right: value ? 2.5 : 72.5,
              bottom: 2.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Puntuación",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: value ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      "Personajes",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: value ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
