import 'dart:io';

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
    const MangasPage(),
    ProfilePage(),
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
        backgroundColor: AnimangaStyle.quaternaryColor,
        body: WillPopScope(onWillPop: _onWillPop, child: pages[_currentIndex]),
        bottomNavigationBar: _buildBottomBar());
  }

  Widget _buildBottomBar() {
    return Container(
        decoration: const BoxDecoration(
            border: Border(
          top: BorderSide(
            color: AnimangaStyle.quaternaryColor,
            width: 1.0,
          ),
        )),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Icon(Icons.home,
                  color: _currentIndex == 0
                      ? AnimangaStyle.primaryColor
                      : AnimangaStyle.whiteColor),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            GestureDetector(
              child: Icon(Icons.add_shopping_cart,
                  color: _currentIndex == 1
                      ? AnimangaStyle.primaryColor
                      : AnimangaStyle.whiteColor),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            GestureDetector(
              child: Icon(Icons.person,
                  color: _currentIndex == 2
                      ? AnimangaStyle.primaryColor
                      : AnimangaStyle.whiteColor),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
          ],
        ));
  }
}
