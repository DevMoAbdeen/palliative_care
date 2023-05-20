import 'package:flutter/material.dart';

class MenuListTile extends StatelessWidget {
  final String thisPageName;
  final IconData icon;
  final String? selectedPageName;
  final VoidCallback? onPressed;

  const MenuListTile({
    Key? key,
    required this.thisPageName,
    required this.icon,
    required this.selectedPageName,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      title: Text(thisPageName),
      textColor: selectedPageName == thisPageName ? Colors.blue : Colors.black,
      leading: Icon(icon),
      iconColor: selectedPageName == thisPageName ? Colors.blue : Colors.black,
    );
  }
}

/////////////////////

class ListTileDrawer extends StatelessWidget {
  final IconData icon;
  final String text;
  final int index;
  final int selectedIndex;
  final Function fun;

  const ListTileDrawer(
      {super.key,
      required this.icon,
      required this.text,
      required this.index,
      required this.selectedIndex,
      required this.fun});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
          icon,
          color: index == selectedIndex ? Colors.blue : Colors.black,
      ),
      title: Text(
        text,
        style: TextStyle(color: index == selectedIndex ? Colors.blue : Colors.black),
      ),
      onTap: () {
        fun();
      },
    );
  }
}
