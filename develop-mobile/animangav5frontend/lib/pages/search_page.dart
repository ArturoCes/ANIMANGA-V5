import 'dart:convert';

import 'package:animangav4frontend/blocs/search/search_bloc.dart';
import 'package:animangav4frontend/models/SearchDto.dart';
import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/rest/rest_client.dart';
import 'package:animangav4frontend/services/mangas_service.dart';
import 'package:animangav4frontend/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final box = GetStorage();
  late MangaService mangaService;
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    mangaService = GetIt.instance<MangaService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
            margin: const EdgeInsets.only(right: 60),
            child: Text(
              "BUSCADOR",
              style: AnimangaStyle.textCustom(
                  AnimangaStyle.whiteColor, AnimangaStyle.textSizeFive),
            ),
          ),
        ),
        backgroundColor: AnimangaStyle.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AnimangaStyle.whiteColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          child: BlocProvider(
              create: (context) {
                return SearchBloc(mangaService);
              },
              child: _createBody(context)),
        ),
      ),
    );
  }

  Widget _createBody(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return buildForm(context);
        } else if (state is SearchErrorState) {
          return buildForm(context);
        } else if (state is SearchSuccessState) {
          return Column(
            children: [buildForm(context), _mangasList(context, state.mangas,10)],
          );
        } else {
          return const Text('Not support');
        }
      },
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Container(
            width: 340,
            height: 50,
            margin: const EdgeInsets.all(10),
            child: TextFormField(
              style: AnimangaStyle.textCustom(
                  AnimangaStyle.blackColor, AnimangaStyle.textSizeTwo),
              controller: searchController,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                filled: true,
                fillColor: AnimangaStyle.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                hintStyle: AnimangaStyle.textCustom(
                    AnimangaStyle.blackColor, AnimangaStyle.textSizeTwo),
                hintText: 'Buscar...',
              ),
              onSaved: (String? value) {},
              validator: (String? value) {
                return (value == null)
                    ? 'Introduzca el nombre del manga'
                    : null;
              },
            ),
          ),
          GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  final searchDto = SearchDto(name: searchController.text);
                  BlocProvider.of<SearchBloc>(context)
                      .add(DoSearchEvent(searchDto));
                }
              },
              child: const Icon(
                Icons.search,
                color: AnimangaStyle.primaryColor,
              ))
        ],
      ),
    );
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
}
