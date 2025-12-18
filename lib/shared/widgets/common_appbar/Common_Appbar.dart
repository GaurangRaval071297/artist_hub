import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Constants/app_colors.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final double? height;
  final Color? backgroundColor;
  final double? elevation;
  final bool? automaticallyImplyLeading;
  final VoidCallback? onBackPressed;

  CommonAppbar({
    this.title,
    this.centerTitle,
    this.actions,
    this.leading,
    this.height = 56.0,
    this.backgroundColor,
    this.elevation,
    this.automaticallyImplyLeading,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(height!);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
        title!,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      )
          : null,
      centerTitle: centerTitle ?? true,
      actions: actions,
      leading: leading ?? _buildDefaultLeading(context),
      backgroundColor: Colors.transparent,
      elevation: elevation ?? 0,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLeading(BuildContext context) {
    // For dashboard screens, show menu icon
    final currentRoute = Get.currentRoute;
    if (currentRoute.contains('dashboard')) {
      return Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      );
    }

    // Check if we can pop
    final canPop = Navigator.canPop(context);

    if (canPop) {
      return IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed ?? () => Get.back(),
      );
    }

    return const SizedBox();
  }
}