import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavigationBarCustom extends StatelessWidget {
  void Function(int)? onTabChange;
  BottomNavigationBarCustom({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Theme.of(context).colorScheme.primary.withOpacity(0.45),
      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.45),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GNav(
        color: Colors.white,
        activeColor: Colors.white,
        // tabBackgroundColor: Colors.grey.shade800,
        tabBackgroundColor:
            Theme.of(context).colorScheme.tertiary.withOpacity(0.55),
        padding: const EdgeInsets.all(16),
        gap: 8,
        onTabChange: (value) => onTabChange!(value),
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.person_add_alt_1,
            text: 'Links',
          ),
          GButton(
            icon: Icons.settings,
            text: 'Settings',
          ),
        ],
      ),
    );
  }
}
