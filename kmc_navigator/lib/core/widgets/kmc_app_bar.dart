import 'package:flutter/material.dart';

/// The app's standard top bar.
///
/// Wrapping [AppBar] here means every secondary screen (Route, Search,
/// Announcements, About, Help) gets identical back-button, title, and
/// action styling from one place instead of repeating `AppBar(...)`
/// configuration across files.
class KmcAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KmcAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), actions: actions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
