import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final double appBarHeight;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.appBarHeight = 80,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/loghi/esempio logo4.png',
            height: 40,
          ),
          if (title != null) const SizedBox(height: 20),
          if (title != null) // Controllo per evitare errori
            Text(
              title!,
              style: const TextStyle(color: Colors.pink),
            ),
        ],
      ),
      leading:
          leading ?? const SizedBox(), // Se leading è null, usa un widget vuoto
      actions: actions,
      toolbarHeight: appBarHeight,
      scrolledUnderElevation: 0,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
