import 'dart:io';

import 'package:animangav4frontend/pages/mangas_favorites_page.dart';
import 'package:animangav4frontend/pages/mangas_page.dart';
import 'package:animangav4frontend/pages/profile_page.dart';
import 'package:animangav4frontend/utils/styles.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  List<Widget> pages = [
    const MangasPage(),
    const FavoritesPage(),
    FavoritesPage(),
  ];
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AnimangaStyle.quaternaryColor,
            content: const Text(
              '¿Deseas salir de la aplicación?',
              style: TextStyle(
                color: AnimangaStyle.whiteColor,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: AnimangaStyle.whiteColor,
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () => exit(0),
                      child: const Text(
                        'Si',
                        style: TextStyle(
                          color: AnimangaStyle.whiteColor,
                        ),
                      )),
                ],
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, //BARRA TRANSPARENTE :D
        body: WillPopScope(onWillPop: _onWillPop, child: pages[_currentIndex]),
        bottomNavigationBar: _buildBottomBar());
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        color: Color.fromARGB(255, 148, 3, 139),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.add_shopping_cart, 1),
          _buildNavItem(Icons.favorite, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      child: Icon(
        icon,
        color: _currentIndex == index ? Colors.white60 : Colors.white,
        size: 30,
      ),
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
