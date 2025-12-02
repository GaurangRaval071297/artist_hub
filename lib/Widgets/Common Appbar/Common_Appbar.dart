import 'package:flutter/material.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final double? height;
  final Color? backgroundColor;
  final double? elevation;
  final bool? automaticallyImplyLeading;

  CommonAppbar({
    this.title,
    this.centerTitle,
    this.actions,
    this.leading,
    this.height = 56.0,
    this.backgroundColor,
    this.elevation,
    this.automaticallyImplyLeading,
  });

  @override
  Size get preferredSize => Size.fromHeight(height!);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
      centerTitle: centerTitle ?? true,
      actions: actions,
      leading: leading,
      backgroundColor: Colors.transparent,
      elevation: elevation ?? 6.0,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.pinkAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
        ],
      ),
    );
  }
}
